import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../models/shop.dart';
import '../../widgets/shop_card.dart';
import '../../widgets/app_bottom_navigation.dart';
import '../../core/routing/app_router.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<Shop> _filteredShops = Shop.mockShops;

  void _onSearchChanged(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredShops = Shop.mockShops;
      } else {
        _filteredShops = Shop.mockShops
            .where((s) =>
                s.name.toLowerCase().contains(query.toLowerCase()) ||
                s.description.toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Search'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushReplacementNamed(context, AppRouter.home);
          },
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              onChanged: _onSearchChanged,
              decoration: InputDecoration(
                hintText: 'Search shops, products, markets...',
                prefixIcon: const Icon(Icons.search, color: AppColors.orange),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          _onSearchChanged('');
                        },
                      )
                    : null,
                filled: true,
                fillColor: AppColors.surface,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.cardBorder),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.cardBorder),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.orange, width: 2),
                ),
              ),
            ),
          ),
          Expanded(
            child: _filteredShops.isEmpty
                ? const Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.search_off, size: 64, color: AppColors.textMuted),
                        SizedBox(height: 12),
                        Text(
                          'No shops or products found',
                          style: TextStyle(
                            fontSize: 16,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _filteredShops.length,
                    itemBuilder: (context, index) {
                      final shop = _filteredShops[index];
                      return ShopCard(
                        shop: shop,
                        onTap: () {
                          Navigator.pushNamed(
                            context,
                            AppRouter.productDetails,
                            arguments: shop,
                          );
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
      bottomNavigationBar: AppBottomNavigation(
        currentIndex: 1,
        onTap: (index) {
          if (index == 1) return;
          if (index == 0) Navigator.pushReplacementNamed(context, AppRouter.home);
          if (index == 2) Navigator.pushReplacementNamed(context, AppRouter.markets);
          if (index == 3) Navigator.pushReplacementNamed(context, AppRouter.favourites);
          if (index == 4) Navigator.pushReplacementNamed(context, AppRouter.account);
        },
      ),
    );
  }
}
