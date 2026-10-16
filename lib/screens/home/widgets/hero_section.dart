import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/routing/app_router.dart';

class HeroSection extends StatefulWidget {
  final ValueChanged<String>? onSearchSubmitted;

  const HeroSection({
    super.key,
    this.onSearchSubmitted,
  });

  @override
  State<HeroSection> createState() => _HeroSectionState();
}

class _HeroSectionState extends State<HeroSection> {
  final TextEditingController _searchController = TextEditingController();

  static const List<Map<String, dynamic>> categoryPills = [
    {'title': 'Electronics', 'icon': Icons.devices_rounded},
    {'title': 'Fashion', 'icon': Icons.checkroom_rounded},
    {'title': 'Home', 'icon': Icons.home_rounded},
    {'title': 'Phones', 'icon': Icons.phone_iphone_rounded},
    {'title': 'Bags', 'icon': Icons.shopping_bag_rounded},
    {'title': 'Footwear', 'icon': Icons.roller_skating_rounded},
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _submitSearch([String? query]) {
    final searchTerm = query ?? _searchController.text;
    Navigator.pushNamed(
      context,
      AppRouter.products,
      arguments: searchTerm,
    );
  }

  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.of(context).size.width;
    final bool isDesktop = width > 800;

    return Container(
      width: double.infinity,
      color: AppColors.darkBackground,
      padding: EdgeInsets.symmetric(
        horizontal: isDesktop ? 48 : 20,
        vertical: isDesktop ? 32 : 16,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Hero Card Container
          Container(
            padding: EdgeInsets.all(isDesktop ? 32 : 20),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.cardBorder),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Headline
                Text(
                  'Great finds. Real shops. Right around you.',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: isDesktop ? 36 : 26,
                    fontWeight: FontWeight.bold,
                    letterSpacing: -0.8,
                  ),
                ),

                const SizedBox(height: 8),

                // Subtitle
                Text(
                  'Discover products you love and the local shops that sell them. Your next find is closer than you think.',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: isDesktop ? 15 : 13,
                    height: 1.4,
                  ),
                ),

                const SizedBox(height: 20),

                // Search Box
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.darkBackground,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.cardBorder),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.search_rounded,
                        color: AppColors.textSecondary,
                        size: 20,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: TextField(
                          controller: _searchController,
                          style: const TextStyle(color: Colors.white, fontSize: 14),
                          onSubmitted: _submitSearch,
                          decoration: const InputDecoration(
                            hintText: 'Search products, shops or markets',
                            hintStyle: TextStyle(
                              color: AppColors.textMuted,
                              fontSize: 14,
                            ),
                            border: InputBorder.none,
                            isDense: true,
                            contentPadding: EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () => _submitSearch(),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.orange,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            'Search Lumo',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Category Pills Grid/Row
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: categoryPills.map((cat) {
                    return GestureDetector(
                      onTap: () => _submitSearch(cat['title'] as String),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: AppColors.darkBackground,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: AppColors.cardBorder),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              cat['icon'] as IconData,
                              color: AppColors.textSecondary,
                              size: 16,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              cat['title'] as String,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
