import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../models/product.dart';
import '../../core/routing/app_router.dart';

class ProductsScreen extends StatefulWidget {
  const ProductsScreen({super.key});

  @override
  State<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
  final List<String> _activeFilters = ['Within 10 km', 'Electronics'];
  bool _audioChecked = true;
  bool _phonesChecked = false;
  bool _computingChecked = false;
  bool _accessoriesChecked = false;

  bool _under2km = true;
  bool _under5km = false;
  bool _under10km = false;

  bool _priceProvided = true;
  bool _recentlyUpdated = false;

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
      appBar: AppBar(title: const Text('Products')),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: isDesktop ? 48 : 20,
            vertical: 16,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Active Filter Chips Row
              Row(
                children: [
                  ..._activeFilters.map(
                    (filter) => Container(
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: surfaceColor,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: borderColor),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            filter,
                            style: TextStyle(color: textColor, fontSize: 12),
                          ),
                          const SizedBox(width: 6),
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                _activeFilters.remove(filter);
                              });
                            },
                            child: Icon(
                              Icons.close,
                              color: secondaryColor,
                              size: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (_activeFilters.isNotEmpty)
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          _activeFilters.clear();
                        });
                      },
                      child: Text(
                        'Clear all',
                        style: TextStyle(
                          color: secondaryColor,
                          fontSize: 12,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                ],
              ),

              const SizedBox(height: 20),

              // Responsive Layout (Desktop: Sidebar Filters + Grid)
              isDesktop
                  ? Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: 260,
                          child: _buildFilterSidebar(
                            surfaceColor,
                            borderColor,
                            textColor,
                            secondaryColor,
                          ),
                        ),
                        const SizedBox(width: 28),
                        Expanded(
                          child: _buildProductsGrid(
                            isDesktop: true,
                            surfaceColor: surfaceColor,
                            borderColor: borderColor,
                            textColor: textColor,
                            secondaryColor: secondaryColor,
                          ),
                        ),
                      ],
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ExpansionTile(
                          title: Text(
                            'Filters',
                            style: TextStyle(
                              color: textColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          children: [
                            _buildFilterSidebar(
                              surfaceColor,
                              borderColor,
                              textColor,
                              secondaryColor,
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        _buildProductsGrid(
                          isDesktop: false,
                          surfaceColor: surfaceColor,
                          borderColor: borderColor,
                          textColor: textColor,
                          secondaryColor: secondaryColor,
                        ),
                      ],
                    ),

              const SizedBox(height: 32),

              // Load More Button
              Center(
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: textColor,
                    side: BorderSide(color: borderColor),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 14,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: () {},
                  child: const Text(
                    'Load more results',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilterSidebar(
    Color surfaceColor,
    Color borderColor,
    Color textColor,
    Color secondaryColor,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Filters',
                style: TextStyle(
                  color: textColor,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              GestureDetector(
                onTap: () {
                  setState(() {
                    _audioChecked = false;
                    _phonesChecked = false;
                    _computingChecked = false;
                    _accessoriesChecked = false;
                  });
                },
                child: Text(
                  'Clear all',
                  style: TextStyle(color: secondaryColor, fontSize: 11),
                ),
              ),
            ],
          ),
          Divider(color: borderColor, height: 24),

          // Category
          Text(
            'Category',
            style: TextStyle(
              color: textColor,
              fontSize: 13,
              fontWeight: FontWeight.bold,
            ),
          ),
          _buildFilterCheckbox(
            'Audio & headphones',
            '14',
            _audioChecked,
            secondaryColor,
            (v) => setState(() => _audioChecked = v!),
          ),
          _buildFilterCheckbox(
            'Phones',
            '11',
            _phonesChecked,
            secondaryColor,
            (v) => setState(() => _phonesChecked = v!),
          ),
          _buildFilterCheckbox(
            'Computing',
            '8',
            _computingChecked,
            secondaryColor,
            (v) => setState(() => _computingChecked = v!),
          ),
          _buildFilterCheckbox(
            'Accessories',
            '5',
            _accessoriesChecked,
            secondaryColor,
            (v) => setState(() => _accessoriesChecked = v!),
          ),

          const SizedBox(height: 16),

          // Distance
          Text(
            'Distance',
            style: TextStyle(
              color: textColor,
              fontSize: 13,
              fontWeight: FontWeight.bold,
            ),
          ),
          _buildFilterCheckbox(
            'Under 2 km',
            '14',
            _under2km,
            secondaryColor,
            (v) => setState(() => _under2km = v!),
          ),
          _buildFilterCheckbox(
            'Under 5 km',
            '11',
            _under5km,
            secondaryColor,
            (v) => setState(() => _under5km = v!),
          ),
          _buildFilterCheckbox(
            'Under 10 km',
            '8',
            _under10km,
            secondaryColor,
            (v) => setState(() => _under10km = v!),
          ),

          const SizedBox(height: 16),

          // Listing info
          Text(
            'Listing information',
            style: TextStyle(
              color: textColor,
              fontSize: 13,
              fontWeight: FontWeight.bold,
            ),
          ),
          _buildFilterCheckbox(
            'Price provided',
            '14',
            _priceProvided,
            secondaryColor,
            (v) => setState(() => _priceProvided = v!),
          ),
          _buildFilterCheckbox(
            'Recently updated',
            '11',
            _recentlyUpdated,
            secondaryColor,
            (v) => setState(() => _recentlyUpdated = v!),
          ),

          const SizedBox(height: 20),

          // Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.orange,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              onPressed: () {},
              child: const Text(
                'Show 24 results',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterCheckbox(
    String label,
    String count,
    bool value,
    Color secondaryColor,
    ValueChanged<bool?> onChanged,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 22,
            height: 22,
            child: Checkbox(
              value: value,
              onChanged: onChanged,
              activeColor: AppColors.orange,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              label,
              style: TextStyle(color: secondaryColor, fontSize: 12),
            ),
          ),
          Text(
            count,
            style: const TextStyle(
              color: AppColors.lightTextMuted,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductsGrid({
    required bool isDesktop,
    required Color surfaceColor,
    required Color borderColor,
    required Color textColor,
    required Color secondaryColor,
  }) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: isDesktop ? 3 : 2,
        childAspectRatio: 0.72,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: Product.mockProducts.length,
      itemBuilder: (context, index) {
        final product = Product.mockProducts[index];
        return _buildProductCardItem(
          context,
          product,
          surfaceColor,
          borderColor,
          textColor,
          secondaryColor,
        );
      },
    );
  }

  Widget _buildProductCardItem(
    BuildContext context,
    Product product,
    Color surfaceColor,
    Color borderColor,
    Color textColor,
    Color secondaryColor,
  ) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(
          context,
          AppRouter.productDetails,
          arguments: product,
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: surfaceColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: borderColor),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(16),
                    ),
                    child: Image.network(
                      product.imageUrl,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          Container(color: surfaceColor),
                    ),
                  ),
                  if (product.isSellerListed)
                    Positioned(
                      bottom: 8,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text(
                          'Seller listed',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      width: 28,
                      height: 28,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.favorite_border,
                        color: Colors.black,
                        size: 16,
                      ),
                    ),
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
                    style: TextStyle(color: secondaryColor, fontSize: 11),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    product.name,
                    style: TextStyle(
                      color: textColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    product.shopName,
                    style: const TextStyle(
                      color: AppColors.lightTextMuted,
                      fontSize: 11,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    product.displayPrice,
                    style: TextStyle(
                      color: textColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 2),
                  const Text(
                    'Illustrative seller price',
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
      ),
    );
  }
}
