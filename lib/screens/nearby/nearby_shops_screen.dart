import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../core/routing/app_router.dart';
import '../../core/theme/app_colors.dart';
import '../../models/product.dart';
import '../../services/location_service.dart';
import '../../services/product_service.dart';
import '../../widgets/app_bottom_navigation.dart';
import '../../widgets/product_favorite_button.dart';

class NearbyShopsScreen extends StatefulWidget {
  const NearbyShopsScreen({super.key});

  @override
  State<NearbyShopsScreen> createState() => _NearbyShopsScreenState();
}

class _NearbyShopsScreenState extends State<NearbyShopsScreen> {
  final LocationService _locationService = LocationService();
  final Stream<List<Product>> _productsStream = ProductService()
      .watchPublishedProducts();
  Position? _position;
  GoogleMapController? _mapController;
  String? _locationError;
  bool _isLoadingLocation = false;
  bool _isMapView = true;

  @override
  void initState() {
    super.initState();
    unawaited(_findPosition());
  }

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }

  Future<void> _findPosition() async {
    setState(() {
      _isLoadingLocation = true;
      _locationError = null;
    });
    try {
      final Position position = await _locationService.getCurrentPosition();
      if (!mounted) return;
      setState(() => _position = position);
      await _mapController?.animateCamera(
        CameraUpdate.newLatLngZoom(
          LatLng(position.latitude, position.longitude),
          13,
        ),
      );
    } catch (error) {
      if (mounted) setState(() => _locationError = error.toString());
    } finally {
      if (mounted) setState(() => _isLoadingLocation = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isDesktop = MediaQuery.sizeOf(context).width > 800;
    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      appBar: AppBar(
        title: const Text('Explore nearby'),
        actions: [
          IconButton(
            tooltip: 'Use my current location',
            onPressed: _isLoadingLocation ? null : _findPosition,
            icon: _isLoadingLocation
                ? const SizedBox.square(
                    dimension: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.my_location),
          ),
        ],
      ),
      body: StreamBuilder<List<Product>>(
        stream: _productsStream,
        builder: (BuildContext context, AsyncSnapshot<List<Product>> snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  'Nearby products could not be loaded: ${snapshot.error}',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final List<Product> products = snapshot.data!;
          final List<Product> locatedProducts = products
              .where(
                (Product product) =>
                    product.shopLatitude != null &&
                    product.shopLongitude != null,
              )
              .toList(growable: false);
          if (isDesktop) {
            return Column(
              children: [
                if (_locationError != null)
                  Padding(
                    padding: const EdgeInsets.all(8),
                    child: Text(
                      _locationError!,
                      style: const TextStyle(color: Colors.amber),
                    ),
                  ),
                Expanded(
                  child: Row(
                    children: [
                      Expanded(child: _buildProductList(products)),
                      Expanded(child: _buildMap(locatedProducts)),
                    ],
                  ),
                ),
              ],
            );
          }
          final List<Product> nearbyProducts = products.toList();
          if (_position != null) {
            double distanceFor(Product product) {
              if (product.shopLatitude == null ||
                  product.shopLongitude == null) {
                return double.infinity;
              }
              return _locationService.calculateDistanceInKm(
                _position!.latitude,
                _position!.longitude,
                product.shopLatitude!,
                product.shopLongitude!,
              );
            }

            nearbyProducts.sort(
              (Product a, Product b) =>
                  distanceFor(a).compareTo(distanceFor(b)),
            );
          }
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        _position == null
                            ? 'Enable location to see your position and nearby listings.'
                            : 'Your current position is shown on the map.',
                        style: const TextStyle(color: AppColors.textSecondary),
                      ),
                    ),
                    SegmentedButton<bool>(
                      segments: const [
                        ButtonSegment<bool>(
                          value: true,
                          icon: Icon(Icons.map_outlined),
                          label: Text('Map'),
                        ),
                        ButtonSegment<bool>(
                          value: false,
                          icon: Icon(Icons.list_alt),
                          label: Text('List'),
                        ),
                      ],
                      selected: <bool>{_isMapView},
                      onSelectionChanged: (Set<bool> selection) =>
                          setState(() => _isMapView = selection.first),
                    ),
                  ],
                ),
              ),
              if (_locationError != null)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    _locationError!,
                    style: const TextStyle(color: Colors.amber),
                    textAlign: TextAlign.center,
                  ),
                ),
              Expanded(
                child: _isMapView
                    ? _buildMap(locatedProducts)
                    : _buildProductList(nearbyProducts),
              ),
            ],
          );
        },
      ),
      bottomNavigationBar: AppBottomNavigation(
        currentIndex: 2,
        onTap: (int index) {
          final String? route = switch (index) {
            0 => AppRouter.home,
            1 => AppRouter.search,
            3 => AppRouter.favourites,
            4 => AppRouter.account,
            _ => null,
          };
          if (route != null) Navigator.pushReplacementNamed(context, route);
        },
      ),
    );
  }

  Widget _buildMap(List<Product> products) {
    final Position? position = _position;
    final LatLng center = position == null
        ? const LatLng(0, 0)
        : LatLng(position.latitude, position.longitude);
    return GoogleMap(
      initialCameraPosition: CameraPosition(
        target: center,
        zoom: position == null ? 2 : 13,
      ),
      myLocationEnabled: position != null,
      myLocationButtonEnabled: false,
      onMapCreated: (GoogleMapController controller) {
        _mapController = controller;
        if (position != null) {
          unawaited(
            controller.animateCamera(CameraUpdate.newLatLngZoom(center, 13)),
          );
        }
      },
      markers: <Marker>{
        for (final Product product in products)
          Marker(
            markerId: MarkerId(product.id),
            position: LatLng(product.shopLatitude!, product.shopLongitude!),
            infoWindow: InfoWindow(
              title: product.name,
              snippet: '${product.shopName} · ${product.displayPrice}',
              onTap: () => Navigator.pushNamed(
                context,
                AppRouter.productDetails,
                arguments: product,
              ),
            ),
          ),
      },
    );
  }

  Widget _buildProductList(List<Product> products) {
    if (products.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text(
            'No products have been published yet.',
            textAlign: TextAlign.center,
          ),
        ),
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: products.length,
      separatorBuilder: (_, _) => const SizedBox(height: 10),
      itemBuilder: (BuildContext context, int index) {
        final Product product = products[index];
        final bool hasCoordinates =
            product.shopLatitude != null && product.shopLongitude != null;
        final double? distance = _position != null && hasCoordinates
            ? _locationService.calculateDistanceInKm(
                _position!.latitude,
                _position!.longitude,
                product.shopLatitude!,
                product.shopLongitude!,
              )
            : null;
        return Card(
          child: ListTile(
            onTap: () => Navigator.pushNamed(
              context,
              AppRouter.productDetails,
              arguments: product,
            ),
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
              '${product.shopName} · '
              '${distance == null ? product.shopLocation : '${distance.toStringAsFixed(1)} km away'}',
            ),
            trailing: ProductFavoriteButton(
              product: product,
              iconColor: AppColors.orange,
            ),
          ),
        );
      },
    );
  }
}
