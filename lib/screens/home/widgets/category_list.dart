import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class CategoryItem {
  final String title;
  final IconData icon;

  const CategoryItem({required this.title, required this.icon});
}

class CategoryList extends StatelessWidget {
  final ValueChanged<String>? onCategorySelected;

  const CategoryList({super.key, this.onCategorySelected});

  static const List<CategoryItem> categories = [
    CategoryItem(title: 'All', icon: Icons.grid_view_rounded),
    CategoryItem(title: 'Electronics', icon: Icons.devices_rounded),
    CategoryItem(title: 'Grocery', icon: Icons.shopping_basket_rounded),
    CategoryItem(title: 'Bakery', icon: Icons.bakery_dining_rounded),
    CategoryItem(title: 'Beverages', icon: Icons.local_cafe_rounded),
    CategoryItem(title: 'Fresh Produce', icon: Icons.eco_rounded),
    CategoryItem(title: 'Crafts', icon: Icons.brush_rounded),
  ];

  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.of(context).size.width;
    final bool isDesktop = width > 800;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(
            horizontal: isDesktop ? 48 : 20,
            vertical: 12,
          ),
          child: const Text(
            'Browse Categories',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
        SizedBox(
          height: 94,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: isDesktop ? 44 : 16),
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final cat = categories[index];
              final isSelected = index == 0;
              return GestureDetector(
                onTap: () => onCategorySelected?.call(cat.title),
                child: Container(
                  width: 80,
                  margin: const EdgeInsets.symmetric(horizontal: 6),
                  child: Column(
                    children: [
                      Container(
                        height: 56,
                        width: 56,
                        decoration: BoxDecoration(
                          color: isSelected ? AppColors.orange : AppColors.surface,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isSelected ? AppColors.orange : AppColors.cardBorder,
                            width: 1.2,
                          ),
                        ),
                        child: Icon(
                          cat.icon,
                          color: isSelected ? Colors.white : AppColors.textSecondary,
                          size: 22,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        cat.title,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                          color: isSelected ? AppColors.orange : AppColors.textSecondary,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
