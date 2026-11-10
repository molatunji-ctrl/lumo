import 'package:flutter/material.dart';

import '../../models/product.dart';
import '../../services/product_service.dart';
import '../../widgets/app_bottom_navigation.dart';
import 'widgets/home_header.dart';
import 'widgets/hero_section.dart';
import 'widgets/category_list.dart';
import '../../core/routing/app_router.dart';
import '../../core/theme/app_colors.dart';
import '../../widgets/product_favorite_button.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  int _currentIndex = 0;

  // Controller to handle the smooth handoff from the Splash Screen
  late final AnimationController _staggerController;

  @override
  void initState() {
    super.initState();
    // Start the cascade animation exactly as the splash screen transitions
    _staggerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..forward();
  }

  @override
  void dispose() {
    _staggerController.dispose();
    super.dispose();
  }

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
    final bool isDesktop = width > 1100;
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
              _FadeSlide(
                controller: _staggerController,
                delay: 0.1,
                child: const HomeHeader(),
              ),
              _FadeSlide(
                controller: _staggerController,
                delay: 0.2,
                child: const HeroSection(),
              ),
              _FadeSlide(
                controller: _staggerController,
                delay: 0.3,
                child: const CategoryList(),
              ),

              SizedBox(height: isDesktop ? 72 : 52),

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
                          'Products at local shops',
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
                child: StreamBuilder<List<Product>>(
                  stream: ProductService().watchPublishedProducts(),
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return Text(
                        'Products could not be loaded: ${snapshot.error}',
                        style: TextStyle(color: secondaryColor),
                      );
                    }
                    if (!snapshot.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    final List<Product> products = snapshot.data!
                        .take(3)
                        .toList(growable: false);
                    if (products.isEmpty) {
                      return Text(
                        'No products have been published yet.',
                        style: TextStyle(color: secondaryColor),
                      );
                    }
                    return GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: isDesktop ? 3 : (width > 500 ? 2 : 1),
                        childAspectRatio: isDesktop ? 0.9 : 0.82,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                      ),
                      itemCount: products.length,
                      itemBuilder: (context, index) => _buildPopularProductCard(
                        context,
                        products[index],
                        surfaceColor,
                        borderColor,
                        textColor,
                        secondaryColor,
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 32),

              // Section 2: Help shoppers plan a physical shop visit.
              _FadeSlide(
                controller: _staggerController,
                delay: 0.6,
                child: _buildVisitGuidanceCard(
                  context,
                  surfaceColor,
                  borderColor,
                  textColor,
                  secondaryColor,
                  isDesktop,
                ),
              ),

              const SizedBox(height: 32),

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
                  Positioned.fill(
                    child: ClipRRect(
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(16),
                      ),
                      child: Image.network(
                        product.imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            Container(color: surfaceColor),
                      ),
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
                    child: ProductFavoriteButton(
                      product: product,
                      iconSize: 16,
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
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVisitGuidanceCard(
    BuildContext context,
    Color surfaceColor,
    Color borderColor,
    Color textColor,
    Color secondaryColor,
    bool isDesktop,
  ) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: isDesktop ? 48 : 20),
      child: Container(
        padding: EdgeInsets.all(isDesktop ? 28 : 20),
        decoration: BoxDecoration(
          color: surfaceColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: borderColor),
        ),
        child: isDesktop
            ? Row(
                children: [
                  _visitGuidanceIcon(),
                  const SizedBox(width: 20),
                  Expanded(
                    child: _visitGuidanceCopy(textColor, secondaryColor),
                  ),
                  const SizedBox(width: 20),
                  _visitGuidanceActions(context),
                ],
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _visitGuidanceIcon(),
                  const SizedBox(height: 16),
                  _visitGuidanceCopy(textColor, secondaryColor),
                  const SizedBox(height: 20),
                  _visitGuidanceActions(context, expand: true),
                ],
              ),
      ),
    );
  }

  Widget _visitGuidanceIcon() {
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        color: AppColors.orange.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Icon(
        Icons.store_mall_directory_outlined,
        color: AppColors.orange,
        size: 28,
      ),
    );
  }

  Widget _visitGuidanceCopy(Color textColor, Color secondaryColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Find a shop. Then plan your visit.',
          style: TextStyle(
            color: textColor,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Explore shops on the map, review the location details, and confirm '
          'price and availability with the seller before travelling.',
          style: TextStyle(color: secondaryColor, height: 1.45),
        ),
      ],
    );
  }

  Widget _visitGuidanceActions(BuildContext context, {bool expand = false}) {
    final List<Widget> buttons = [
      FilledButton.icon(
        onPressed: () => Navigator.pushNamed(context, AppRouter.nearby),
        icon: const Icon(Icons.map_outlined),
        label: const Text('Explore nearby'),
      ),
      OutlinedButton.icon(
        onPressed: () => Navigator.pushNamed(context, AppRouter.products),
        icon: const Icon(Icons.search_rounded),
        label: const Text('Browse products'),
      ),
    ];
    if (expand) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [buttons[0], const SizedBox(height: 8), buttons[1]],
      );
    }
    return Wrap(
      spacing: 10,
      runSpacing: 8,
      alignment: WrapAlignment.end,
      children: buttons,
    );
  }
}

// --- MICRO-INTERACTION COMPONENT ---
// Add this to the bottom of the file to handle the staggered slide-in effect
class _FadeSlide extends StatelessWidget {
  final AnimationController controller;
  final double delay;
  final Widget child;

  const _FadeSlide({
    required this.controller,
    required this.delay,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final curve = CurvedAnimation(
      parent: controller,
      curve: Interval(
        delay,
        (delay + 0.4).clamp(0.0, 1.0),
        curve: Curves.easeOutCubic,
      ),
    );

    return AnimatedBuilder(
      animation: curve,
      builder: (context, child) {
        return Opacity(
          opacity: curve.value,
          child: Transform.translate(
            offset: Offset(0, 30 * (1 - curve.value)),
            child: child,
          ),
        );
      },
      child: child,
    );
  }
}
