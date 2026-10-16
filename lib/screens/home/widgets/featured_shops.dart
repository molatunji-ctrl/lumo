import 'package:flutter/material.dart';
import '../../../models/shop.dart';
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
    final double width = MediaQuery.of(context).size.width;
    final bool isDesktop = width > 800;
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    final Color textColor = isDarkMode ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final Color surfaceColor = isDarkMode ? AppColors.darkSurface : AppColors.lightSurface;
    final Color borderColor = isDarkMode ? AppColors.darkCardBorder : AppColors.lightCardBorder;
    final Color secondaryColor = isDarkMode ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: isDesktop ? 48 : 20,
        vertical: 12,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'NEAR YOU',
            style: TextStyle(
              color: AppColors.orange,
              fontSize: 11,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Shops worth a visit',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
              GestureDetector(
                onTap: onSeeAllTap ??
                    () {
                      Navigator.pushNamed(context, AppRouter.nearby);
                    },
                child: Row(
                  children: [
                    Text(
                      'View all',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: secondaryColor,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      Icons.arrow_forward_rounded,
                      size: 14,
                      color: secondaryColor,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          isDesktop
              ? Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 5,
                      child: Column(
                        children: shops
                            .take(2)
                            .map((shop) => _buildShopRowCard(context, shop, surfaceColor, borderColor, textColor, secondaryColor))
                            .toList(),
                      ),
                    ),
                    const SizedBox(width: 24),
                    Expanded(
                      flex: 6,
                      child: _buildInteractiveMapCard(context, isDarkMode),
                    ),
                  ],
                )
              : Column(
                  children: [
                    ...shops
                        .take(2)
                        .map((shop) => _buildShopRowCard(context, shop, surfaceColor, borderColor, textColor, secondaryColor)),
                    const SizedBox(height: 16),
                    _buildInteractiveMapCard(context, isDarkMode),
                  ],
                ),
        ],
      ),
    );
  }

  Widget _buildShopRowCard(
    BuildContext context,
    Shop shop,
    Color surfaceColor,
    Color borderColor,
    Color textColor,
    Color secondaryColor,
  ) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(
          context,
          AppRouter.shopDetails,
          arguments: shop,
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: surfaceColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: borderColor),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                shop.imageUrl,
                width: 90,
                height: 90,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                    Container(width: 90, height: 90, color: surfaceColor),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        shop.name,
                        style: TextStyle(
                          color: textColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.green.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.verified, color: AppColors.green, size: 12),
                            SizedBox(width: 3),
                            Text(
                              'Verified',
                              style: TextStyle(
                                color: AppColors.green,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    shop.category,
                    style: TextStyle(
                      color: secondaryColor,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.location_on_outlined,
                          size: 13, color: AppColors.orange),
                      const SizedBox(width: 3),
                      Expanded(
                        child: Text(
                          shop.address,
                          style: const TextStyle(
                            color: AppColors.textMuted,
                            fontSize: 11,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        shop.distance,
                        style: TextStyle(
                          color: textColor,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Row(
                        children: [
                          Text(
                            'View shop',
                            style: TextStyle(
                              color: AppColors.orange,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(width: 4),
                          Icon(Icons.arrow_forward_rounded,
                              size: 14, color: AppColors.orange),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInteractiveMapCard(BuildContext context, bool isDarkMode) {
    return Container(
      height: 220,
      decoration: BoxDecoration(
        color: isDarkMode ? AppColors.darkSurface : AppColors.lightSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDarkMode ? AppColors.darkCardBorder : AppColors.lightCardBorder,
        ),
      ),
      child: Stack(
        children: [
          // Simulated Map Background
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
              color: isDarkMode ? const Color(0xFF131D2E) : const Color(0xFFE5EDE6),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Center(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Positioned(
                    top: 50,
                    left: 60,
                    child: _mapPin('1', isDarkMode),
                  ),
                  Positioned(
                    bottom: 60,
                    right: 80,
                    child: _mapPin('4', isDarkMode),
                  ),
                  Positioned(
                    bottom: 40,
                    left: 100,
                    child: _mapPin('3', isDarkMode),
                  ),
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: AppColors.orange,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                    child: const Icon(Icons.storefront, color: Colors.white, size: 20),
                  ),
                ],
              ),
            ),
          ),

          // Bottom Floating Map Card
          Positioned(
            bottom: 12,
            left: 12,
            right: 12,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: isDarkMode ? AppColors.darkSurface.withOpacity(0.95) : Colors.white.withOpacity(0.95),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isDarkMode ? AppColors.darkCardBorder : AppColors.lightCardBorder,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Explore Ikeja',
                        style: TextStyle(
                          color: isDarkMode ? Colors.white : AppColors.lightTextPrimary,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 2),
                      const Text(
                        '36 shops and 4 markets nearby',
                        style: TextStyle(
                          color: AppColors.textMuted,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.orange,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    ),
                    onPressed: () {
                      Navigator.pushNamed(context, AppRouter.nearby);
                    },
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Open map',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(width: 4),
                        Icon(Icons.arrow_forward_rounded, size: 14, color: Colors.white),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _mapPin(String label, bool isDarkMode) {
    return Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        color: isDarkMode ? const Color(0xFF1E2D4A) : const Color(0xFF2C3E50),
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 2),
      ),
      child: Center(
        child: Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 11,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
