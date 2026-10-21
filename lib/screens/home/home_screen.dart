import 'package:flutter/material.dart';

import '../../models/shop.dart';
import '../../models/product.dart';
import '../../models/market.dart';
import '../../widgets/app_bottom_navigation.dart';
import 'widgets/home_header.dart';
import 'widgets/hero_section.dart';
import 'widgets/category_list.dart';
import 'widgets/featured_shops.dart';
import '../../core/routing/app_router.dart';
import '../../core/theme/app_colors.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  void _onBottomNavTapped(int index) {
    if (index == _currentIndex) return;
    setState(() => _currentIndex = index);

    switch (index) {
      case 0:
        break; // Home / Discover
      case 1:
        Navigator.pushReplacementNamed(context, AppRouter.search);
        break;
      case 2:
        Navigator.pushReplacementNamed(context, AppRouter.nearby);
        break;
      case 3:
        Navigator.pushReplacementNamed(context, AppRouter.favourites);
        break;
      case 4:
        Navigator.pushReplacementNamed(context, AppRouter.account);
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.of(context).size.width;
    final bool isDesktop = width > 800;
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    final Color bgColor = isDarkMode
        ? AppColors.darkBackground
        : AppColors.lightBackground;
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

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const HomeHeader(),
              const HeroSection(),
              const CategoryList(),

              const SizedBox(height: 24),

              // Section 1: DISCOVER -> Products to discover
              Padding(
                padding: EdgeInsets.symmetric(horizontal: isDesktop ? 48 : 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'DISCOVER',
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
                          'Products to discover',
                          style: TextStyle(
                            color: textColor,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.pushNamed(context, AppRouter.products);
                          },
                          child: Row(
                            children: [
                              Text(
                                'See all products',
                                style: TextStyle(
                                  color: secondaryColor,
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
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
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Popular Products Grid
              Padding(
                padding: EdgeInsets.symmetric(horizontal: isDesktop ? 48 : 20),
                child: GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: isDesktop ? 3 : (width > 500 ? 2 : 1),
                    childAspectRatio: isDesktop ? 0.9 : 0.82,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                  ),
                  itemCount: 3,
                  itemBuilder: (context, index) {
                    final product = Product
                        .mockProducts[index % Product.mockProducts.length];
                    return _buildPopularProductCard(
                      context,
                      product,
                      surfaceColor,
                      borderColor,
                      textColor,
                      secondaryColor,
                    );
                  },
                ),
              ),

              const SizedBox(height: 32),

              // Section 2: NEAR YOU -> Shops worth a visit
              FeaturedShops(shops: Shop.mockShops),

              const SizedBox(height: 32),

              // Section 3: Markets to explore
              Padding(
                padding: EdgeInsets.symmetric(horizontal: isDesktop ? 48 : 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Markets to explore',
                          style: TextStyle(
                            color: textColor,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.pushNamed(context, AppRouter.markets);
                          },
                          child: Row(
                            children: [
                              Text(
                                'Explore markets',
                                style: TextStyle(
                                  color: secondaryColor,
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
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
                            children: [
                              Expanded(
                                child: _buildMarketTile(
                                  context,
                                  Market.mockMarkets[0],
                                  surfaceColor,
                                  borderColor,
                                  textColor,
                                  secondaryColor,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: _buildMarketTile(
                                  context,
                                  Market.mockMarkets[1],
                                  surfaceColor,
                                  borderColor,
                                  textColor,
                                  secondaryColor,
                                ),
                              ),
                            ],
                          )
                        : Column(
                            children: [
                              _buildMarketTile(
                                context,
                                Market.mockMarkets[0],
                                surfaceColor,
                                borderColor,
                                textColor,
                                secondaryColor,
                              ),
                              const SizedBox(height: 12),
                              _buildMarketTile(
                                context,
                                Market.mockMarkets[1],
                                surfaceColor,
                                borderColor,
                                textColor,
                                secondaryColor,
                              ),
                            ],
                          ),
                  ],
                ),
              ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
      bottomNavigationBar: AppBottomNavigation(
        currentIndex: _currentIndex,
        onTap: _onBottomNavTapped,
      ),
    );
  }

  Widget _buildPopularProductCard(
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
                      bottom: 10,
                      left: 10,
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
                    top: 10,
                    right: 10,
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

  Widget _buildMarketTile(
    BuildContext context,
    Market market,
    Color surfaceColor,
    Color borderColor,
    Color textColor,
    Color secondaryColor,
  ) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, AppRouter.markets);
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
                market.imageUrl,
                width: 64,
                height: 64,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                    Container(width: 64, height: 64, color: surfaceColor),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    market.name,
                    style: TextStyle(
                      color: textColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${market.location} · ${market.description}',
                    style: TextStyle(color: secondaryColor, fontSize: 12),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_rounded, color: textColor, size: 18),
          ],
        ),
      ),
    );
  }
}
