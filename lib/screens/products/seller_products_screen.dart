import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../models/product.dart';
import '../../services/location_service.dart';
import '../../services/product_service.dart';

class SellerProductsScreen extends StatelessWidget {
  const SellerProductsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('My products')),
        body: const Center(child: Text('Sign in to manage your products.')),
      );
    }

    final ProductService service = ProductService();
    return Scaffold(
      appBar: AppBar(
        title: const Text('My products'),
        actions: [
          IconButton(
            tooltip: 'Add product',
            onPressed: () => _editProduct(context),
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _editProduct(context),
        icon: const Icon(Icons.add),
        label: const Text('Add product'),
      ),
      body: StreamBuilder<List<Product>>(
        stream: service.watchSellerProducts(user.uid),
        builder: (BuildContext context, AsyncSnapshot<List<Product>> snapshot) {
          if (snapshot.hasError) {
            return _Message(
              message: 'Could not load your products: ${snapshot.error}',
            );
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final List<Product> products = snapshot.data!;
          if (products.isEmpty) {
            return const _Message(
              icon: Icons.storefront_outlined,
              message: 'Your listings will appear here. Add a product to get started.',
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
            itemCount: products.length,
            separatorBuilder: (_, _) => const SizedBox(height: 10),
            itemBuilder: (BuildContext context, int index) {
              final Product product = products[index];
              return Card(
                child: ListTile(
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      product.imageUrl,
                      width: 56,
                      height: 56,
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => const SizedBox(
                        width: 56,
                        height: 56,
                        child: Icon(Icons.image_not_supported_outlined),
                      ),
                    ),
                  ),
                  title: Text(product.name),
                  subtitle: Text(
                    '${product.displayPrice} · '
                    '${product.isPublished ? 'Published' : 'Draft'}',
                  ),
                  trailing: IconButton(
                    tooltip: 'Edit product',
                    icon: const Icon(Icons.edit_outlined),
                    onPressed: () => _editProduct(context, product),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Future<void> _editProduct(BuildContext context, [Product? product]) async {
    await Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (_) => SellerProductFormScreen(product: product),
      ),
    );
  }
}

class SellerProductFormScreen extends StatefulWidget {
  const SellerProductFormScreen({this.product, super.key});

  final Product? product;

  @override
  State<SellerProductFormScreen> createState() =>
      _SellerProductFormScreenState();
}

class _SellerProductFormScreenState extends State<SellerProductFormScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _priceController;
  late final TextEditingController _shopController;
  late final TextEditingController _locationController;
  late final TextEditingController _categoryController;
  late final TextEditingController _latitudeController;
  late final TextEditingController _longitudeController;
  final ProductService _service = ProductService();
  final LocationService _locationService = LocationService();
  String? _imageUrl;
  bool _isPublished = true;
  bool _isSaving = false;
  bool _isUploading = false;
  bool _isLocatingShop = false;

  @override
  void initState() {
    super.initState();
    final Product? product = widget.product;
    _nameController = TextEditingController(text: product?.name ?? '');
    _descriptionController = TextEditingController(
      text: product?.description ?? '',
    );
    _priceController = TextEditingController(
      text: product?.price?.toString() ?? '',
    );
    _shopController = TextEditingController(text: product?.shopName ?? '');
    _locationController = TextEditingController(
      text: product?.shopLocation ?? '',
    );
    _categoryController = TextEditingController(text: product?.category ?? '');
    _latitudeController = TextEditingController(
      text: product?.shopLatitude?.toString() ?? '',
    );
    _longitudeController = TextEditingController(
      text: product?.shopLongitude?.toString() ?? '',
    );
    _imageUrl = product?.imageUrl;
    _isPublished = product?.isPublished ?? true;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _shopController.dispose();
    _locationController.dispose();
    _categoryController.dispose();
    _latitudeController.dispose();
    _longitudeController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    setState(() => _isUploading = true);
    try {
      final String? url = await _service.pickAndUploadImage();
      if (mounted && url != null) setState(() => _imageUrl = url);
    } catch (error) {
      if (!mounted) return;
      _showMessage('Could not upload the image: $error');
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_imageUrl == null || _imageUrl!.isEmpty) {
      _showMessage('Add a product image before saving.');
      return;
    }
    final double? latitude = _coordinate(_latitudeController.text);
    final double? longitude = _coordinate(_longitudeController.text);
    if ((latitude == null) != (longitude == null)) {
      _showMessage('Enter both map coordinates, or leave both blank.');
      return;
    }
    setState(() => _isSaving = true);
    try {
      final Product product = Product(
        id: widget.product?.id ?? '',
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim(),
        price: double.parse(_priceController.text.trim()),
        imageUrl: _imageUrl!,
        shopName: _shopController.text.trim(),
        shopLocation: _locationController.text.trim(),
        category: _categoryController.text.trim(),
        sellerUid: FirebaseAuth.instance.currentUser!.uid,
        isPublished: _isPublished,
        shopLatitude: latitude,
        shopLongitude: longitude,
      );
      await _service.saveProduct(product, existingId: widget.product?.id);
      if (mounted) Navigator.of(context).pop();
    } catch (error) {
      if (mounted) _showMessage('Could not save product: $error');
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _useCurrentLocation() async {
    setState(() => _isLocatingShop = true);
    try {
      final position = await _locationService.getCurrentPosition();
      if (!mounted) return;
      setState(() {
        _latitudeController.text = position.latitude.toStringAsFixed(6);
        _longitudeController.text = position.longitude.toStringAsFixed(6);
      });
    } catch (error) {
      if (mounted) _showMessage('Could not get your location: $error');
    } finally {
      if (mounted) setState(() => _isLocatingShop = false);
    }
  }

  double? _coordinate(String input) {
    final String value = input.trim();
    return value.isEmpty ? null : double.tryParse(value);
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.product == null ? 'Add product' : 'Edit product'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            OutlinedButton.icon(
              onPressed: _isUploading ? null : _pickImage,
              icon: _isUploading
                  ? const SizedBox.square(
                      dimension: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.add_photo_alternate_outlined),
              label: Text(
                _imageUrl == null ? 'Choose product photo' : 'Change photo',
              ),
            ),
            if (_imageUrl case final String imageUrl) ...[
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  imageUrl,
                  height: 180,
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) => const SizedBox(
                    height: 100,
                    child: Center(child: Text('Image could not be displayed')),
                  ),
                ),
              ),
            ],
            const SizedBox(height: 20),
            _field(_nameController, 'Product name'),
            _field(_descriptionController, 'Description', maxLines: 3),
            _field(
              _priceController,
              'Price (NGN)',
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              validator: (value) {
                final double? price = double.tryParse(value?.trim() ?? '');
                return price == null || price <= 0
                    ? 'Enter a price greater than zero'
                    : null;
              },
            ),
            _field(_categoryController, 'Category'),
            _field(_shopController, 'Shop name'),
            _field(_locationController, 'Shop location'),
            const SizedBox(height: 8),
            Text(
              'Optional map pin',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 4),
            const Text(
              'Only listings with coordinates can appear as pins on the nearby map.',
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                onPressed: _isLocatingShop ? null : _useCurrentLocation,
                icon: _isLocatingShop
                    ? const SizedBox.square(
                        dimension: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.my_location),
                label: const Text('Use this device’s current location'),
              ),
            ),
            Row(
              children: [
                Expanded(
                  child: _field(
                    _latitudeController,
                    'Latitude',
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                      signed: true,
                    ),
                    required: false,
                    validator: (value) {
                      final double? coordinate = _coordinate(value ?? '');
                      return (value?.trim().isNotEmpty ?? false) &&
                              (coordinate == null ||
                                  coordinate < -90 ||
                                  coordinate > 90)
                          ? 'Invalid latitude'
                          : null;
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _field(
                    _longitudeController,
                    'Longitude',
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                      signed: true,
                    ),
                    required: false,
                    validator: (value) {
                      final double? coordinate = _coordinate(value ?? '');
                      return (value?.trim().isNotEmpty ?? false) &&
                              (coordinate == null ||
                                  coordinate < -180 ||
                                  coordinate > 180)
                          ? 'Invalid longitude'
                          : null;
                    },
                  ),
                ),
              ],
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Publish listing'),
              subtitle: const Text(
                'Published listings are visible to everyone.',
              ),
              value: _isPublished,
              onChanged: (bool value) => setState(() => _isPublished = value),
            ),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: _isSaving || _isUploading ? null : _save,
              child: _isSaving
                  ? const SizedBox.square(
                      dimension: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Save product'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _field(
    TextEditingController controller,
    String label, {
    int maxLines = 1,
    TextInputType? keyboardType,
    bool required = true,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        validator:
            validator ??
            (value) => required && (value == null || value.trim().isEmpty)
                ? 'Required'
                : null,
      ),
    );
  }
}

class _Message extends StatelessWidget {
  const _Message({
    required this.message,
    this.icon = Icons.inventory_2_outlined,
  });

  final String message;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 52),
            const SizedBox(height: 12),
            Text(message, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
