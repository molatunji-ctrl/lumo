import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../models/product.dart';
import '../../core/routing/app_router.dart';
import '../../widgets/product_favorite_button.dart';

class ProductDetailsScreen extends StatelessWidget {
  final Product product;

  const ProductDetailsScreen({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.of(context).size.width;
    final bool isDesktop = width > 800;
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    final Color bgColor = isDarkMode
        ? AppColors.darkBackground
        : AppColors.lightBackground;
    final Color surfaceColor = isDarkMode
        ? AppColors.darkSurface
        : AppColors.lightSurface;
    final Color borderColor = isDarkMode
        ? AppColors.darkCardBorder
        : AppColors.lightCardBorder;
    final Color textColor = isDarkMode
        ? AppColors.darkTextPrimary
        : AppColors.lightTextPrimary;
    final Color secondaryColor = isDarkMode
        ? AppColors.darkTextSecondary
        : AppColors.lightTextSecondary;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: Text(product.name),
        backgroundColor: bgColor,
        foregroundColor: textColor,
        elevation: 0,
        actions: [
          ProductFavoriteButton(
            product: product,
            backgroundColor: Colors.transparent,
            iconColor: textColor,
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: isDesktop ? 48 : 20,
            vertical: 16,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Breadcrumbs
              Text(
                'Discover / ${product.category} / ${product.name}',
                style: TextStyle(color: secondaryColor, fontSize: 12),
              ),

              const SizedBox(height: 16),

              // Product Main Section (Desktop: Left Image, Right Info)
              isDesktop
                  ? Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 5,
                          child: _buildProductImage(
                            product,
                            isDesktop,
                            surfaceColor,
                            borderColor,
                          ),
                        ),
                        const SizedBox(width: 32),
                        Expanded(
                          flex: 5,
                          child: _buildProductDetails(
                            product,
                            textColor,
                            secondaryColor,
                            surfaceColor,
                            borderColor,
                          ),
                        ),
                      ],
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildProductImage(
                          product,
                          isDesktop,
                          surfaceColor,
                          borderColor,
                        ),
                        const SizedBox(height: 20),
                        _buildProductDetails(
                          product,
                          textColor,
                          secondaryColor,
                          surfaceColor,
                          borderColor,
                        ),
                      ],
                    ),

              const SizedBox(height: 32),

              // Section 2: Find it at a local shop
              Text(
                'Find it at a local shop',
                style: TextStyle(
                  color: textColor,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 12),

              _buildLocalShopCard(
                context,
                surfaceColor,
                borderColor,
                textColor,
                secondaryColor,
              ),

              const SizedBox(height: 32),

              OutlinedButton.icon(
                onPressed: () =>
                    Navigator.pushNamed(context, AppRouter.products),
                icon: const Icon(Icons.storefront_outlined),
                label: const Text('Browse published products'),
              ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProductImage(
    Product product,
    bool isDesktop,
    Color surfaceColor,
    Color borderColor,
  ) {
    return Container(
      height: isDesktop ? 340 : 250,
      width: double.infinity,
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Image.network(
          product.imageUrl,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) =>
              Container(color: surfaceColor),
        ),
      ),
    );
  }

  Widget _buildProductDetails(
    Product product,
    Color textColor,
    Color secondaryColor,
    Color surfaceColor,
    Color borderColor,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          product.category.toUpperCase(),
          style: const TextStyle(
            color: AppColors.lightTextMuted,
            fontSize: 11,
            fontWeight: FontWeight.bold,
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          product.name,
          style: TextStyle(
            color: textColor,
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          product.displayPrice,
          style: TextStyle(
            color: textColor,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          product.isPublished
              ? 'Published listing · confirm availability with the seller.'
              : 'Draft listing',
          style: const TextStyle(color: AppColors.lightTextMuted, fontSize: 11),
        ),
        const SizedBox(height: 16),
        Text(
          product.description,
          style: TextStyle(color: secondaryColor, fontSize: 13, height: 1.5),
        ),
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: surfaceColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: borderColor),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Before you visit',
                style: TextStyle(
                  color: textColor,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Brand, material, dimensions and colour options have not been supplied. Ask the shop to confirm specifications and current pricing.',
                style: TextStyle(
                  color: AppColors.lightTextMuted,
                  fontSize: 11,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLocalShopCard(
    BuildContext context,
    Color surfaceColor,
    Color borderColor,
    Color textColor,
    Color secondaryColor,
  ) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.storefront_outlined,
            size: 44,
            color: AppColors.orange,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.shopName,
                  style: TextStyle(
                    color: textColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  product.shopLocation,
                  style: TextStyle(color: secondaryColor, fontSize: 12),
                ),
                const SizedBox(height: 2),
                const Text(
                  'Contact the seller to confirm current availability.',
                  style: TextStyle(
                    color: AppColors.lightTextMuted,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
