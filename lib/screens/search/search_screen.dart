import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../models/product.dart';
import '../../models/shop.dart';
import '../../models/market.dart';
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
  String _currentQuery = '';
  bool _hasSearched = false;
  int _selectedTab = 0; // 0: Products, 1: Shops, 2: Markets
  String _sortMode = 'Relevance';

  // Filter Checkboxes
  bool _audioChecked = false;
  bool _phonesChecked = false;
  bool _computingChecked = false;
  bool _accessoriesChecked = false;

  bool _under2km = false;
  bool _under5km = false;
  bool _under10km = false;

  bool _priceProvided = false;
  bool _recentlyUpdated = false;

  final Set<String> _favouriteProductIds = {};

  final List<String> _popularSuggestions = [
    'Wireless earbuds',
    'iPhone 15',
    'Sneakers',
    'Leather tote',
    'Office chairs',
    'Computing',
  ];

  final List<String> _recentSearches = [
    'Electronics in Ikeja',
    'Fashion shops',
    'Fresh produce market',
  ];

  @override
  void initState() {
    super.initState();
    if (widget.initialQuery != null && widget.initialQuery!.trim().isNotEmpty) {
      _currentQuery = widget.initialQuery!.trim();
      _hasSearched = true;
      _searchController = TextEditingController(text: _currentQuery);
      _audioChecked = true;
      _under2km = true;
      _priceProvided = true;
    } else {
      _currentQuery = '';
      _hasSearched = false;
      _searchController = TextEditingController();
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchSubmitted([String? text]) {
    final query = (text ?? _searchController.text).trim();
    setState(() {
      _currentQuery = query;
      _hasSearched = query.isNotEmpty;
      if (query.isNotEmpty) {
        _searchController.text = query;
      }
    });
  }

  void _selectSuggestion(String text) {
    _searchController.text = text;
    _onSearchSubmitted(text);
  }

  // Active Filter Tags computed dynamically
  List<String> get _activeFilterTags {
    final tags = <String>[];
    if (_under2km || _under5km || _under10km) tags.add('Within 10 km');
    if (_audioChecked) tags.add('Audio & headphones');
    if (_phonesChecked) tags.add('Phones');
    if (_computingChecked) tags.add('Computing');
    if (_accessoriesChecked) tags.add('Accessories');
    if (_priceProvided) tags.add('Price provided');
    return tags;
  }

  void _removeFilterTag(String tag) {
    setState(() {
      if (tag == 'Within 10 km') {
        _under2km = false;
        _under5km = false;
        _under10km = false;
      } else if (tag == 'Audio & headphones') {
        _audioChecked = false;
      } else if (tag == 'Phones') {
        _phonesChecked = false;
      } else if (tag == 'Computing') {
        _computingChecked = false;
      } else if (tag == 'Accessories') {
        _accessoriesChecked = false;
      } else if (tag == 'Price provided') {
        _priceProvided = false;
      }
    });
  }

  void _clearAllFilters() {
    setState(() {
      _audioChecked = false;
      _phonesChecked = false;
      _computingChecked = false;
      _accessoriesChecked = false;
      _under2km = false;
      _under5km = false;
      _under10km = false;
      _priceProvided = false;
      _recentlyUpdated = false;
    });
  }

  List<Product> get _filteredProducts {
    final query = _currentQuery.trim().toLowerCase();

    var products = Product.mockProducts.where((product) {
      final matchesQuery = query.isEmpty ||
          product.name.toLowerCase().contains(query) ||
          product.description.toLowerCase().contains(query) ||
          product.category.toLowerCase().contains(query) ||
          product.shopName.toLowerCase().contains(query) ||
          product.shopLocation.toLowerCase().contains(query);

      final selectedCategories = <String>[
        if (_audioChecked) 'audio',
        if (_phonesChecked) 'phone',
        if (_computingChecked) 'comput',
        if (_accessoriesChecked) 'accessor',
      ];

      final matchesCategory = selectedCategories.isEmpty ||
          selectedCategories.any(
            (category) => product.category.toLowerCase().contains(category),
          );

      final matchesPrice = !_priceProvided ||
          product.price != null ||
          (product.formattedPrice != null &&
              product.formattedPrice != 'Price not provided');

      return matchesQuery && matchesCategory && matchesPrice;
    }).toList();

    // Sort products
    if (_sortMode == 'Price: Low to High') {
      products.sort((a, b) => (a.price ?? 0).compareTo(b.price ?? 0));
    } else if (_sortMode == 'Price: High to Low') {
      products.sort((a, b) => (b.price ?? 0).compareTo(a.price ?? 0));
    }

    return products;
  }

  List<Shop> get _filteredShops {
    final query = _currentQuery.trim().toLowerCase();

    return Shop.mockShops.where((shop) {
      return query.isEmpty ||
          shop.name.toLowerCase().contains(query) ||
          shop.description.toLowerCase().contains(query) ||
          shop.category.toLowerCase().contains(query) ||
          shop.address.toLowerCase().contains(query) ||
          shop.marketName.toLowerCase().contains(query);
    }).toList();
  }

  List<Market> get _filteredMarkets {
    final query = _currentQuery.trim().toLowerCase();

    return Market.mockMarkets.where((market) {
      return query.isEmpty ||
          market.name.toLowerCase().contains(query) ||
          market.location.toLowerCase().contains(query) ||
          market.description.toLowerCase().contains(query);
    }).toList();
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

              // Search Input Box (Always Visible)
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
                              onChanged: (val) {
                                if (val.isEmpty && _hasSearched) {
                                  setState(() {
                                    _hasSearched = false;
                                    _currentQuery = '';
                                  });
                                }
                              },
                              decoration: InputDecoration(
                                hintText: 'Search products, shops or markets...',
                                hintStyle: const TextStyle(
                                  color: AppColors.lightTextMuted,
                                  fontSize: 14,
                                ),
                                border: InputBorder.none,
                                isDense: true,
                                contentPadding: const EdgeInsets.symmetric(vertical: 12),
                                suffixIcon: _searchController.text.isNotEmpty
                                    ? IconButton(
                                        icon: const Icon(Icons.clear, size: 18),
                                        onPressed: () {
                                          _searchController.clear();
                                          setState(() {
                                            _hasSearched = false;
                                            _currentQuery = '';
                                          });
                                        },
                                      )
                                    : null,
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

              // CONDITIONAL BODY: Introduction State VS Search Results State
              if (!_hasSearched)
                _buildIntroductionState(
                  isDesktop: isDesktop,
                  surfaceColor: surfaceColor,
                  borderColor: borderColor,
                  textColor: textColor,
                  secondaryColor: secondaryColor,
                )
              else
                _buildSearchResultsState(
                  isDesktop: isDesktop,
                  surfaceColor: surfaceColor,
                  borderColor: borderColor,
                  textColor: textColor,
                  secondaryColor: secondaryColor,
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

  // --- 1. INTRODUCTION / NEW USER EMPTY SEARCH VIEW ---
  Widget _buildIntroductionState({
    required bool isDesktop,
    required Color surfaceColor,
    required Color borderColor,
    required Color textColor,
    required Color secondaryColor,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: isDesktop ? 48 : 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Welcome Banner Container
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(isDesktop ? 32 : 20),
            decoration: BoxDecoration(
              color: surfaceColor,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: borderColor),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.orange.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        'DISCOVER LUMO',
                        style: TextStyle(
                          color: AppColors.orange,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  'What products do you want to find?',
                  style: TextStyle(
                    color: textColor,
                    fontSize: isDesktop ? 28 : 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Search thousands of products, compare local shops, and explore vibrant markets around Ikeja, Lagos.',
                  style: TextStyle(
                    color: secondaryColor,
                    fontSize: 14,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Popular Searches Section
          const Text(
            'POPULAR SEARCHES',
            style: TextStyle(
              color: AppColors.lightTextMuted,
              fontSize: 11,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 12),

          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: _popularSuggestions.map((suggestion) {
              return GestureDetector(
                onTap: () => _selectSuggestion(suggestion),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: surfaceColor,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: borderColor),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.trending_up_rounded,
                          size: 16, color: AppColors.orange),
                      const SizedBox(width: 8),
                      Text(
                        suggestion,
                        style: TextStyle(
                          color: textColor,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),

          const SizedBox(height: 28),

          // Recent Searches Section
          const Text(
            'RECENT SEARCHES',
            style: TextStyle(
              color: AppColors.lightTextMuted,
              fontSize: 11,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 12),

          Column(
            children: _recentSearches.map((recent) {
              return GestureDetector(
                onTap: () => _selectSuggestion(recent),
                child: Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: surfaceColor,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: borderColor),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.history_rounded,
                              size: 18, color: secondaryColor),
                          const SizedBox(width: 12),
                          Text(
                            recent,
                            style: TextStyle(
                              color: textColor,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      Icon(Icons.north_west_rounded,
                          size: 16, color: secondaryColor),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  // --- 2. ACTIVE SEARCH RESULTS STATE ---
  Widget _buildSearchResultsState({
    required bool isDesktop,
    required Color surfaceColor,
    required Color borderColor,
    required Color textColor,
    required Color secondaryColor,
  }) {
    final products = _filteredProducts;
    final shops = _filteredShops;
    final markets = _filteredMarkets;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Search Title & Sort/Filter Controls
        Padding(
          padding: EdgeInsets.symmetric(horizontal: isDesktop ? 48 : 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Column(
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
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${products.length} results from listings around Ikeja',
                      style: const TextStyle(
                        color: AppColors.lightTextMuted,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              if (isDesktop)
                Row(
                  children: [
                    // Sort Dropdown
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: surfaceColor,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: borderColor),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _sortMode,
                          dropdownColor: surfaceColor,
                          icon: Icon(Icons.tune_rounded, size: 16, color: textColor),
                          style: TextStyle(
                            color: textColor,
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                          ),
                          items: const [
                            DropdownMenuItem(
                                value: 'Relevance', child: Text('Sort: Relevance')),
                            DropdownMenuItem(
                                value: 'Price: Low to High',
                                child: Text('Sort: Price Low to High')),
                            DropdownMenuItem(
                                value: 'Price: High to Low',
                                child: Text('Sort: Price High to Low')),
                          ],
                          onChanged: (val) {
                            if (val != null) {
                              setState(() => _sortMode = val);
                            }
                          },
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),

                    // Filters Badge Button
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: surfaceColor,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: borderColor),
                      ),
                      child: Row(
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
                            child: Text(
                              '${_activeFilterTags.length}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),

        const SizedBox(height: 20),

        // Category Tabs (Products | Shops | Markets)
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
                _buildTabItem('Products', '${products.length}', index: 0, textColor: textColor),
                const SizedBox(width: 24),
                _buildTabItem('Shops', '${shops.length}', index: 1, textColor: textColor),
                const SizedBox(width: 24),
                _buildTabItem('Markets', '${markets.length}', index: 2, textColor: textColor),
              ],
            ),
          ),
        ),

        const SizedBox(height: 16),

        // Active Filters Row
        if (_selectedTab == 0 && _activeFilterTags.isNotEmpty)
          Padding(
            padding: EdgeInsets.symmetric(horizontal: isDesktop ? 48 : 20),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                ..._activeFilterTags.map(
                  (tag) => Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: surfaceColor,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: borderColor),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          tag,
                          style: TextStyle(
                            color: textColor,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(width: 6),
                        GestureDetector(
                          onTap: () => _removeFilterTag(tag),
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
                GestureDetector(
                  onTap: _clearAllFilters,
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

        // TAB CONTENT VIEW
        if (_selectedTab == 0)
          _buildProductsTabContent(
            isDesktop: isDesktop,
            products: products,
            surfaceColor: surfaceColor,
            borderColor: borderColor,
            textColor: textColor,
            secondaryColor: secondaryColor,
          )
        else if (_selectedTab == 1)
          _buildShopsTabContent(
            isDesktop: isDesktop,
            shops: shops,
            surfaceColor: surfaceColor,
            borderColor: borderColor,
            textColor: textColor,
            secondaryColor: secondaryColor,
          )
        else
          _buildMarketsTabContent(
            isDesktop: isDesktop,
            markets: markets,
            surfaceColor: surfaceColor,
            borderColor: borderColor,
            textColor: textColor,
            secondaryColor: secondaryColor,
          ),
      ],
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
                color: isSelected
                    ? AppColors.orange.withValues(alpha: 0.15)
                    : Colors.transparent,
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

  Widget _buildProductsTabContent({
    required bool isDesktop,
    required List<Product> products,
    required Color surfaceColor,
    required Color borderColor,
    required Color textColor,
    required Color secondaryColor,
  }) {
    return Padding(
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
                    products.length,
                  ),
                ),
                const SizedBox(width: 28),
                Expanded(
                  child: _buildProductsGrid(
                    isDesktop: true,
                    products: products,
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
                    'Filters (${_activeFilterTags.length} active)',
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
                      products.length,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _buildProductsGrid(
                  isDesktop: false,
                  products: products,
                  surfaceColor: surfaceColor,
                  borderColor: borderColor,
                  textColor: textColor,
                  secondaryColor: secondaryColor,
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
    int resultCount,
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
                onTap: _clearAllFilters,
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
              child: Text(
                'Show $resultCount results',
                style: const TextStyle(
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
    required List<Product> products,
    required Color surfaceColor,
    required Color borderColor,
    required Color textColor,
    required Color secondaryColor,
  }) {
    if (products.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            children: [
              const Icon(Icons.search_off, size: 64, color: AppColors.lightTextMuted),
              const SizedBox(height: 12),
              Text(
                'No products match your filters',
                style: TextStyle(color: textColor, fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: _clearAllFilters,
                child: const Text('Reset all filters', style: TextStyle(color: AppColors.orange)),
              ),
            ],
          ),
        ),
      );
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: isDesktop ? 3 : 2,
        childAspectRatio: 0.72,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: products.length,
      itemBuilder: (context, index) {
        final product = products[index];
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
    final isFav = _favouriteProductIds.contains(product.id) || product.isFavourite;

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
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          if (isFav) {
                            _favouriteProductIds.remove(product.id);
                          } else {
                            _favouriteProductIds.add(product.id);
                          }
                        });
                      },
                      child: Container(
                        width: 28,
                        height: 28,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          isFav ? Icons.favorite : Icons.favorite_border,
                          color: isFav ? AppColors.orange : Colors.black,
                          size: 16,
                        ),
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

  Widget _buildShopsTabContent({
    required bool isDesktop,
    required List<Shop> shops,
    required Color surfaceColor,
    required Color borderColor,
    required Color textColor,
    required Color secondaryColor,
  }) {
    if (shops.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Text('No shops found matching "$_currentQuery"',
              style: TextStyle(color: textColor, fontSize: 16)),
        ),
      );
    }

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: isDesktop ? 48 : 20),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: isDesktop ? 2 : 1,
          childAspectRatio: isDesktop ? 2.2 : 2.5,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        itemCount: shops.length,
        itemBuilder: (context, index) {
          final shop = shops[index];
          return GestureDetector(
            onTap: () {
              Navigator.pushNamed(
                context,
                AppRouter.shopDetails,
                arguments: shop,
              );
            },
            child: Container(
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
                      width: 80,
                      height: 80,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          Container(width: 80, height: 80, color: surfaceColor),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          shop.name,
                          style: TextStyle(
                            color: textColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
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
                        Text(
                          '${shop.address} · ${shop.distance}',
                          style: const TextStyle(
                            color: AppColors.lightTextMuted,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildMarketsTabContent({
    required bool isDesktop,
    required List<Market> markets,
    required Color surfaceColor,
    required Color borderColor,
    required Color textColor,
    required Color secondaryColor,
  }) {
    if (markets.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Text('No markets found matching "$_currentQuery"',
              style: TextStyle(color: textColor, fontSize: 16)),
        ),
      );
    }

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: isDesktop ? 48 : 20),
      child: Column(
        children: markets.map((market) {
          return GestureDetector(
            onTap: () {
              Navigator.pushNamed(context, AppRouter.markets);
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
                      market.imageUrl,
                      width: 70,
                      height: 70,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          Container(width: 70, height: 70, color: surfaceColor),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          market.name,
                          style: TextStyle(
                            color: textColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${market.location} · ${market.description}',
                          style: TextStyle(
                            color: secondaryColor,
                            fontSize: 12,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${market.shopCount} active shops',
                          style: const TextStyle(
                            color: AppColors.lightTextMuted,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_rounded,
                    color: textColor,
                    size: 18,
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
