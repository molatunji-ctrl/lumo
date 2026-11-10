import 'package:flutter/material.dart';

import '../../core/routing/app_router.dart';
import '../../core/theme/app_colors.dart';
import '../../models/product.dart';
import '../../services/product_service.dart';
import '../../widgets/product_favorite_button.dart';

class ProductsScreen extends StatelessWidget {
  const ProductsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ProductService service = ProductService();
    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      appBar: AppBar(title: const Text('Products')),
      body: StreamBuilder<List<Product>>(
        stream: service.watchPublishedProducts(),
        builder: (BuildContext context, AsyncSnapshot<List<Product>> snapshot) {
          if (snapshot.hasError) {
            return _ProductsMessage(
              message: 'Products could not be loaded: ${snapshot.error}',
            );
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final List<Product> products = snapshot.data!;
          if (products.isEmpty) {
            return const _ProductsMessage(
              icon: Icons.storefront_outlined,
              message: 'No products have been published yet. Check back soon or add your own listing from your account.',
            );
          }
          final int columns = MediaQuery.sizeOf(context).width > 800 ? 3 : 2;
          return GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: columns,
              childAspectRatio: 0.62,
              crossAxisSpacing: 14,
              mainAxisSpacing: 14,
            ),
            itemCount: products.length,
            itemBuilder: (BuildContext context, int index) =>
                _ProductCard(product: products[index]),
          );
        },
      ),
    );
  }
}

class _ProductCard extends StatelessWidget {
  const _ProductCard({required this.product});

  final Product product;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(14),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => Navigator.pushNamed(
          context,
          AppRouter.productDetails,
          arguments: product,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(
                    product.imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => const ColoredBox(
                      color: AppColors.darkBackground,
                      child: Icon(Icons.image_not_supported_outlined),
                    ),
                  ),
                  Positioned(
                    top: 4,
                    right: 4,
                    child: ProductFavoriteButton(product: product),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.category,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 11,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    product.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    product.shopName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    product.displayPrice,
                    style: const TextStyle(
                      color: AppColors.orange,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProductsMessage extends StatelessWidget {
  const _ProductsMessage({
    required this.message,
    this.icon = Icons.cloud_off_outlined,
  });

  final String message;
  final IconData icon;

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(28),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 56, color: AppColors.textMuted),
          const SizedBox(height: 12),
          Text(message, textAlign: TextAlign.center),
        ],
      ),
    ),
  );
}
