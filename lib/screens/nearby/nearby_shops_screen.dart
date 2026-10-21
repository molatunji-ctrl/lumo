import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../models/shop.dart';
import '../../widgets/app_bottom_navigation.dart';
import '../../core/routing/app_router.dart';

class NearbyShopsScreen extends StatefulWidget {
  const NearbyShopsScreen({super.key});

  @override
  State<NearbyShopsScreen> createState() => _NearbyShopsScreenState();
}

class _NearbyShopsScreenState extends State<NearbyShopsScreen> {
  String _activeTab = 'Browse this area';
  bool _isMapView = false;

  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.of(context).size.width;
    final bool isDesktop = width > 800;

    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      appBar: AppBar(
        title: const Text('Explore Nearby'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushReplacementNamed(context, AppRouter.home);
          },
        ),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: isDesktop ? 48 : 20,
                vertical: 20,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Headline & Subtitle
                  Text(
                    'Good finds, just around the corner.',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: isDesktop ? 32 : 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Exploring Ikeja, Lagos · Area selected manually. Distances are unavailable.',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 13,
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Filter Tabs
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _buildFilterTab(
                          'Browse this area',
                          isSelected: _activeTab == 'Browse this area',
                        ),
                        const SizedBox(width: 8),
                        _buildFilterTab(
                          'All places',
                          isSelected: _activeTab == 'All places',
                        ),
                        const SizedBox(width: 8),
                        _buildFilterTab(
                          'Shops',
                          isSelected: _activeTab == 'Shops',
                        ),
                        const SizedBox(width: 8),
                        _buildFilterTab(
                          'Markets',
                          isSelected: _activeTab == 'Markets',
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Content Split (Desktop/Tablet 2 columns, Phone stacked)
                  isDesktop
                      ? Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              flex: 5,
                              child: _buildShopListSection(context),
                            ),
                            const SizedBox(width: 24),
                            Expanded(flex: 7, child: _buildMapPreviewSection()),
                          ],
                        )
                      : (_isMapView
                            ? _buildMapPreviewSection(height: 500)
                            : _buildShopListSection(context)),

                  const SizedBox(height: 20),

                  // Disclaimer
                  const Center(
                    child: Text(
                      'Lumo design preview · Fictional listings and illustrative imagery. Confirm details with each shop before visiting.',
                      style: TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 11,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 60),
                ],
              ),
            ),
          ),

          // Floating Map / List Toggle Button for Mobile
          if (!isDesktop)
            Positioned(
              bottom: 24,
              left: 0,
              right: 0,
              child: Center(
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _isMapView = !_isMapView;
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.navy,
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(
                        color: AppColors.cardBorder,
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.4),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _isMapView
                              ? Icons.format_list_bulleted_rounded
                              : Icons.map_rounded,
                          color: Colors.white,
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _isMapView ? 'List' : 'Map',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
      bottomNavigationBar: AppBottomNavigation(
        currentIndex: 2,
        onTap: (index) {
          if (index == 2) return;
          if (index == 0)
            Navigator.pushReplacementNamed(context, AppRouter.home);
          if (index == 1)
            Navigator.pushReplacementNamed(context, AppRouter.search);
          if (index == 3)
            Navigator.pushReplacementNamed(context, AppRouter.favourites);
          if (index == 4)
            Navigator.pushReplacementNamed(context, AppRouter.account);
        },
      ),
    );
  }

  Widget _buildFilterTab(String title, {required bool isSelected}) {
    return GestureDetector(
      onTap: () {
        setState(() => _activeTab = title);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.orange : AppColors.surface,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? AppColors.orange : AppColors.cardBorder,
          ),
        ),
        child: Text(
          title,
          style: TextStyle(
            color: Colors.white,
            fontSize: 13,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildShopListSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Discover the area',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),

        // Shop Card 1: Kora Collective
        _buildAreaShopCard(
          context,
          shop: Shop.mockShops[0],
          subtitle: 'Fashion & accessories · Ikeja',
        ),

        const SizedBox(height: 12),

        // Shop Card 2: Computer Village
        _buildAreaShopCard(
          context,
          shop: Shop.mockShops[2],
          subtitle: 'Shopping area · Ikeja, Lagos',
        ),
      ],
    );
  }

  Widget _buildAreaShopCard(
    BuildContext context, {
    required Shop shop,
    required String subtitle,
  }) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, AppRouter.shopDetails, arguments: shop);
      },
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.cardBorder),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                shop.imageUrl,
                height: 120,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                    Container(height: 120, color: AppColors.darkBackground),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              shop.name,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 2),
            const Text(
              'Sample shop · Identity unverified',
              style: TextStyle(color: AppColors.textMuted, fontSize: 11),
            ),
            const SizedBox(height: 8),
            const Text(
              'Discover this shop',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMapPreviewSection({double height = 420}) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        children: [
          Expanded(
            child: Stack(
              children: [
                // Map background
                Container(
                  width: double.infinity,
                  color: const Color(0xFF131D2E),
                  child: Center(
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        const Text(
                          'IKEJA',
                          style: TextStyle(
                            color: AppColors.cardBorder,
                            fontSize: 48,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 4,
                          ),
                        ),
                        // Shop Pin 1
                        Positioned(
                          left: 80,
                          top: 100,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.darkBackground,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: AppColors.cardBorder),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.location_on,
                                  color: AppColors.orange,
                                  size: 14,
                                ),
                                SizedBox(width: 4),
                                Text(
                                  'Kora Collective',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        // Shop Pin 2
                        Positioned(
                          right: 60,
                          top: 80,
                          child: Container(
                            width: 32,
                            height: 32,
                            decoration: const BoxDecoration(
                              color: AppColors.orange,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.storefront,
                              color: Colors.white,
                              size: 18,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Disclaimer Footer
          Container(
            padding: const EdgeInsets.all(14),
            decoration: const BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(16)),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Map preview — Illustrative only',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Not a navigable map. Browse the place list instead. User maps and location placeholders will be connected during development.',
                  style: TextStyle(color: AppColors.textMuted, fontSize: 11),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
