import 'package:flutter/material.dart';
import '../../../models/shop.dart';
import '../../../widgets/shop_card.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/routing/app_router.dart';

class FeaturedShops extends StatelessWidget {
  final List<Shop> shops;
  final VoidCallback? onSeeAllTap;

  const FeaturedShops({
    super.key,
    required this.shops,
    this.onSeeAllTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Featured Shops',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              GestureDetector(
                onTap: onSeeAllTap ??
                    () {
                      Navigator.pushNamed(context, AppRouter.nearby);
                    },
                child: const Text(
                  'See All',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppColors.orange,
                  ),
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: shops
                .map(
                  (shop) => ShopCard(
                    shop: shop,
                    onTap: () {
                      Navigator.pushNamed(
                        context,
                        AppRouter.productDetails,
                        arguments: shop,
                      );
                    },
                  ),
                )
                .toList(),
          ),
        ),
      ],
    );
  }
}
