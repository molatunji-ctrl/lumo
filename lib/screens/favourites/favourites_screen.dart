import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../models/product.dart';
import '../../widgets/app_bottom_navigation.dart';
import '../../core/routing/app_router.dart';

class FavouritesScreen extends StatelessWidget {
  const FavouritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Product> favourites = Product.mockProducts
        .where((Product p) => p.isFavourite)
        .toList();

    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      appBar: AppBar(
        title: const Text('Favourites'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushReplacementNamed(context, AppRouter.home);
          },
        ),
      ),
      body: favourites.isEmpty
          ? const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.favorite_outline,
                    size: 64,
                    color: AppColors.textMuted,
                  ),
                  SizedBox(height: 12),
                  Text(
                    'No saved favourites yet',
                    style: TextStyle(
                      fontSize: 16,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: favourites.length,
              itemBuilder: (BuildContext context, int index) {
                final Product item = favourites[index];
                final String itemPriceText = item.displayPrice;
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.cardBorder),
                  ),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          item.imageUrl,
                          width: 70,
                          height: 70,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              Container(
                                width: 70,
                                height: 70,
                                color: AppColors.darkBackground,
                              ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              item.shopName,
                              style: const TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              itemPriceText,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: AppColors.orange,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.favorite, color: AppColors.orange),
                    ],
                  ),
                );
              },
            ),
      bottomNavigationBar: AppBottomNavigation(
        currentIndex: 3,
        onTap: (int index) {
          if (index == 3) return;
          if (index == 0)
            Navigator.pushReplacementNamed(context, AppRouter.home);
          if (index == 1)
            Navigator.pushReplacementNamed(context, AppRouter.search);
          if (index == 2)
            Navigator.pushReplacementNamed(context, AppRouter.nearby);
          if (index == 4)
            Navigator.pushReplacementNamed(context, AppRouter.account);
        },
      ),
    );
  }
}
