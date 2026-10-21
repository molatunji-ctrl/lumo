import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/routing/app_router.dart';

class CategoryCardItem {
  final String title;
  final String code;
  final IconData icon;

  const CategoryCardItem({
    required this.title,
    required this.code,
    required this.icon,
  });
}

class CategoryList extends StatelessWidget {
  const CategoryList({super.key});

  static const List<CategoryCardItem> categories = [
    CategoryCardItem(
      title: 'Phones',
      code: 'PH',
      icon: Icons.phone_iphone_rounded,
    ),
    CategoryCardItem(
      title: 'Fashion',
      code: 'FA',
      icon: Icons.checkroom_rounded,
    ),
    CategoryCardItem(title: 'Home', code: 'HO', icon: Icons.home_rounded),
    CategoryCardItem(title: 'Beauty', code: 'BE', icon: Icons.face_rounded),
    CategoryCardItem(
      title: 'Groceries',
      code: 'GR',
      icon: Icons.shopping_basket_rounded,
    ),
    CategoryCardItem(
      title: 'Computing',
      code: 'CO',
      icon: Icons.computer_rounded,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.of(context).size.width;
    final bool isDesktop = width > 800;
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    final Color textColor = isDarkMode
        ? AppColors.darkTextPrimary
        : AppColors.lightTextPrimary;
    final Color surfaceColor = isDarkMode
        ? AppColors.darkSurface
        : AppColors.lightSurface;
    final Color borderColor = isDarkMode
        ? AppColors.darkCardBorder
        : AppColors.lightCardBorder;
    final Color secondaryColor = isDarkMode
        ? AppColors.darkTextSecondary
        : AppColors.lightTextSecondary;

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: isDesktop ? 48 : 20,
        vertical: 12,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Browse by category',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
              GestureDetector(
                onTap: () {
                  Navigator.pushNamed(context, AppRouter.products);
                },
                child: Row(
                  children: [
                    Text(
                      'All categories',
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
          SizedBox(
            height: 100,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: categories.length,
              itemBuilder: (context, index) {
                final cat = categories[index];
                return GestureDetector(
                  onTap: () {
                    Navigator.pushNamed(context, AppRouter.products);
                  },
                  child: Container(
                    width: 110,
                    margin: const EdgeInsets.only(right: 12),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: surfaceColor,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: borderColor),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: isDarkMode
                                ? AppColors.darkBackground
                                : AppColors.lightBackground,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: borderColor),
                          ),
                          child: Text(
                            cat.code,
                            style: TextStyle(
                              color: textColor,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          cat.title,
                          style: TextStyle(
                            color: textColor,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
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
      ),
    );
  }
}
