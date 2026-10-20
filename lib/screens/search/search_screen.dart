import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../models/product.dart';
import '../../widgets/app_bottom_navigation.dart';
import '../home/widgets/home_header.dart';
import '../../core/routing/app_router.dart';

class SearchScreen extends StatefulWidget {
  final String? initialQuery;

  const SearchScreen({super.key, this.initialQuery});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  late final TextEditingController _searchController;
  String _currentQuery = 'Wireless earbuds';
  int _selectedTab = 0; // 0: Products (24), 1: Shops (12), 2: Markets (3)

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
  void initState() {
    super.initState();
    _currentQuery = widget.initialQuery ?? 'Wireless earbuds';
    _searchController = TextEditingController(text: _currentQuery);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchSubmitted([String? text]) {
    setState(() {
      _currentQuery = text ?? _searchController.text;
      if (_currentQuery.isEmpty) _currentQuery = 'Wireless earbuds';
    });
  }

  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.of(context).size.width;
    final bool isDesktop = width > 800;
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    final Color bgColor = isDarkMode ? AppColors.darkBackground : AppColors.lightBackground;
    final Color surfaceColor = isDarkMode ? AppColors.darkSurface : AppColors.lightSurface;
    final Color borderColor = isDarkMode ? AppColors.darkCardBorder : AppColors.lightCardBorder;
    final Color textColor = isDarkMode ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final Color secondaryColor = isDarkMode ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const HomeHeader(),

              // Search Bar Box
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: isDesktop ? 48 : 20,
                  vertical: 16,
                ),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 720),
                    child: Container(
                      decoration: BoxDecoration(
                        color: surfaceColor,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: borderColor),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                      child: Row(
                        children: [
                          Icon(
                            Icons.search_rounded,
                            color: secondaryColor,
                            size: 20,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: TextField(
                              controller: _searchController,
                              style: TextStyle(color: textColor, fontSize: 14),
                              onSubmitted: _onSearchSubmitted,
                              decoration: const InputDecoration(
                                hintText: 'Search products, shops or markets',
                                hintStyle: TextStyle(
                                  color: AppColors.lightTextMuted,
                                  fontSize: 14,
                                ),
                                border: InputBorder.none,
                                isDense: true,
                                contentPadding: EdgeInsets.symmetric(vertical: 12),
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: () => _onSearchSubmitted(),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 10,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.orange,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Text(
                                'Search',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // Search Title & Sort / Filter controls
              Padding(
                padding: EdgeInsets.symmetric(horizontal: isDesktop ? 48 : 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'SEARCH RESULTS',
                          style: TextStyle(
                            color: AppColors.lightTextMuted,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.2,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '"$_currentQuery"',
                          style: TextStyle(
                            color: textColor,
                            fontSize: isDesktop ? 32 : 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          '24 results from listings around Ikeja',
                          style: TextStyle(
                            color: AppColors.lightTextMuted,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                    if (isDesktop)
                      Row(
                        children: [
                          _buildActionButton(
                            icon: Icons.tune_rounded,
                            label: 'Sort: Relevance',
                            surfaceColor: surfaceColor,
                            borderColor: borderColor,
                            textColor: textColor,
                          ),
                          const SizedBox(width: 12),
                          _buildFilterButtonWithBadge(
                            surfaceColor: surfaceColor,
                            borderColor: borderColor,
                            textColor: textColor,
                          ),
                        ],
                      ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Result Category Tabs (Products 24 | Shops 12 | Markets 3)
              Padding(
                padding: EdgeInsets.symmetric(horizontal: isDesktop ? 48 : 20),
                child: Container(
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(color: borderColor, width: 1),
                    ),
                  ),
                  child: Row(
                    children: [
                      _buildTabItem('Products', '24', index: 0, textColor: textColor),
                      const SizedBox(width: 24),
                      _buildTabItem('Shops', '12', index: 1, textColor: textColor),
                      const SizedBox(width: 24),
                      _buildTabItem('Markets', '3', index: 2, textColor: textColor),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Active Filters Row
              Padding(
                padding: EdgeInsets.symmetric(horizontal: isDesktop ? 48 : 20),
                child: Row(
                  children: [
                    ..._activeFilters.map(
                      (filter) => Container(
                        margin: const EdgeInsets.only(right: 8),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
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
                              style: TextStyle(
                                color: textColor,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
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
                        child: const Text(
                          'Clear all',
                          style: TextStyle(
                            color: AppColors.lightTextMuted,
                            fontSize: 12,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Main Content (Sidebar + Product Grid)
              Padding(
                padding: EdgeInsets.symmetric(horizontal: isDesktop ? 48 : 20),
                child: isDesktop
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
              ),

              const SizedBox(height: 32),

              // Load More Button
              Center(
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    backgroundColor: surfaceColor,
                    foregroundColor: textColor,
                    side: BorderSide(color: borderColor),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 32, vertical: 14),
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
      bottomNavigationBar: AppBottomNavigation(
        currentIndex: 1,
        onTap: (index) {
          if (index == 1) return;
          if (index == 0) Navigator.pushReplacementNamed(context, AppRouter.home);
          if (index == 2) Navigator.pushReplacementNamed(context, AppRouter.nearby);
          if (index == 3) Navigator.pushReplacementNamed(context, AppRouter.favourites);
          if (index == 4) Navigator.pushReplacementNamed(context, AppRouter.account);
        },
      ),
    );
  }

  Widget _buildTabItem(String title, String count,
      {required int index, required Color textColor}) {
    final bool isSelected = _selectedTab == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedTab = index),
      child: Container(
        padding: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: isSelected ? AppColors.orange : Colors.transparent,
              width: 2,
            ),
          ),
        ),
        child: Row(
          children: [
            Text(
              title,
              style: TextStyle(
                color: isSelected ? textColor : AppColors.lightTextMuted,
                fontSize: 15,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              ),
            ),
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.orange.withValues(alpha: 0.15) : Colors.transparent,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                count,
                style: TextStyle(
                  color: isSelected ? AppColors.orange : AppColors.lightTextMuted,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color surfaceColor,
    required Color borderColor,
    required Color textColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: textColor),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: textColor,
              fontSize: 13,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterButtonWithBadge({
    required Color surfaceColor,
    required Color borderColor,
    required Color textColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.filter_list_rounded, size: 16, color: textColor),
          const SizedBox(width: 6),
          Text(
            'Filters',
            style: TextStyle(
              color: textColor,
              fontSize: 13,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: 6),
          Container(
            padding: const EdgeInsets.all(5),
            decoration: const BoxDecoration(
              color: AppColors.orange,
              shape: BoxShape.circle,
            ),
            child: const Text(
              '2',
              style: TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
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
                child: const Text(
                  'Clear all',
                  style: TextStyle(
                    color: AppColors.lightTextMuted,
                    fontSize: 11,
                  ),
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
          _buildFilterCheckbox('Audio & headphones', '14', _audioChecked, secondaryColor,
              (v) => setState(() => _audioChecked = v!)),
          _buildFilterCheckbox('Phones', '11', _phonesChecked, secondaryColor,
              (v) => setState(() => _phonesChecked = v!)),
          _buildFilterCheckbox('Computing', '8', _computingChecked, secondaryColor,
              (v) => setState(() => _computingChecked = v!)),
          _buildFilterCheckbox('Accessories', '5', _accessoriesChecked, secondaryColor,
              (v) => setState(() => _accessoriesChecked = v!)),

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
          _buildFilterCheckbox('Under 2 km', '14', _under2km, secondaryColor,
              (v) => setState(() => _under2km = v!)),
          _buildFilterCheckbox('Under 5 km', '11', _under5km, secondaryColor,
              (v) => setState(() => _under5km = v!)),
          _buildFilterCheckbox('Under 10 km', '8', _under10km, secondaryColor,
              (v) => setState(() => _under10km = v!)),

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
          _buildFilterCheckbox('Price provided', '14', _priceProvided, secondaryColor,
              (v) => setState(() => _priceProvided = v!)),
          _buildFilterCheckbox('Recently updated', '11', _recentlyUpdated, secondaryColor,
              (v) => setState(() => _recentlyUpdated = v!)),

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
              style: TextStyle(
                color: secondaryColor,
                fontSize: 12,
              ),
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
            context, product, surfaceColor, borderColor, textColor, secondaryColor);
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
                    borderRadius:
                        const BorderRadius.vertical(top: Radius.circular(16)),
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
                            horizontal: 8, vertical: 4),
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
                    style: TextStyle(
                      color: secondaryColor,
                      fontSize: 11,
                    ),
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
