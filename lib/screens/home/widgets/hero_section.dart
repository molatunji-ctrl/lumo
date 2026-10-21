import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/routing/app_router.dart';

class HeroSection extends StatefulWidget {
  final ValueChanged<String>? onSearchSubmitted;

  const HeroSection({super.key, this.onSearchSubmitted});

  @override
  State<HeroSection> createState() => _HeroSectionState();
}

class _HeroSectionState extends State<HeroSection> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _submitSearch([String? query]) {
    final searchTerm = query ?? _searchController.text;
    Navigator.pushNamed(context, AppRouter.products, arguments: searchTerm);
  }

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
    final Color searchBgColor = isDarkMode
        ? AppColors.darkSurface
        : Colors.white;

    return Container(
      width: double.infinity,
      color: bgColor,
      padding: EdgeInsets.symmetric(
        horizontal: isDesktop ? 48 : 20,
        vertical: isDesktop ? 36 : 20,
      ),
      child: isDesktop
          ? Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  flex: 5,
                  child: _buildTextAndSearchContent(
                    isDesktop: true,
                    isDarkMode: isDarkMode,
                    textColor: textColor,
                    secondaryColor: secondaryColor,
                    searchBgColor: searchBgColor,
                    borderColor: borderColor,
                  ),
                ),
                const SizedBox(width: 48),
                Expanded(
                  flex: 5,
                  child: _buildHeroImageCard(
                    isDesktop: true,
                    isDarkMode: isDarkMode,
                    surfaceColor: surfaceColor,
                    borderColor: borderColor,
                  ),
                ),
              ],
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTextAndSearchContent(
                  isDesktop: false,
                  isDarkMode: isDarkMode,
                  textColor: textColor,
                  secondaryColor: secondaryColor,
                  searchBgColor: searchBgColor,
                  borderColor: borderColor,
                ),
                const SizedBox(height: 32),
                _buildHeroImageCard(
                  isDesktop: false,
                  isDarkMode: isDarkMode,
                  surfaceColor: surfaceColor,
                  borderColor: borderColor,
                ),
              ],
            ),
    );
  }

  Widget _buildTextAndSearchContent({
    required bool isDesktop,
    required bool isDarkMode,
    required Color textColor,
    required Color secondaryColor,
    required Color searchBgColor,
    required Color borderColor,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Pill Tag: Discover what's around you
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(
            color: isDarkMode
                ? const Color(0xFF241B1A)
                : const Color(0xFFFFF2EC),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0x66FF8A3D), width: 1),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.auto_awesome, color: AppColors.orange, size: 14),
              const SizedBox(width: 6),
              Text(
                "Discover what's around you",
                style: TextStyle(
                  color: AppColors.orange,
                  fontSize: isDesktop ? 13 : 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 20),

        // Headline
        Text(
          'Find it nearby.\nShop with\nconfidence.',
          style: TextStyle(
            color: textColor,
            fontSize: isDesktop ? 54 : 38,
            fontWeight: FontWeight.w800,
            height: 1.08,
            letterSpacing: -1.2,
          ),
        ),

        const SizedBox(height: 16),

        // Subtitle
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: Text(
            'Search real products, compare local shops, and find your way there—all in one place.',
            style: TextStyle(
              color: secondaryColor,
              fontSize: isDesktop ? 16 : 14,
              height: 1.45,
            ),
          ),
        ),

        const SizedBox(height: 28),

        // Search Bar Box
        Container(
          decoration: BoxDecoration(
            color: searchBgColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: borderColor, width: 1.2),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          child: Row(
            children: [
              Icon(Icons.search_rounded, color: secondaryColor, size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: TextField(
                  controller: _searchController,
                  style: TextStyle(color: textColor, fontSize: 14),
                  onSubmitted: _submitSearch,
                  decoration: const InputDecoration(
                    hintText: 'Search products, shops or markets',
                    hintStyle: TextStyle(
                      color: AppColors.lightTextMuted,
                      fontSize: 14,
                    ),
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(vertical: 10),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: () => _submitSearch(),
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: isDesktop ? 20 : 12,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.orange,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: isDesktop
                      ? const Text(
                          'Search',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        )
                      : const Icon(
                          Icons.arrow_forward_rounded,
                          color: Colors.white,
                          size: 18,
                        ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Popular Searches
        Wrap(
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 8,
          runSpacing: 6,
          children: [
            Text(
              'Popular:',
              style: TextStyle(color: secondaryColor, fontSize: 13),
            ),
            _buildPopularTag('iPhone 15', textColor),
            _buildPopularTag('Office chairs', textColor),
            _buildPopularTag('Sneakers', textColor),
          ],
        ),
      ],
    );
  }

  Widget _buildPopularTag(String text, Color textColor) {
    return GestureDetector(
      onTap: () => _submitSearch(text),
      child: Text(
        text,
        style: TextStyle(
          color: textColor,
          fontSize: 13,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildHeroImageCard({
    required bool isDesktop,
    required bool isDarkMode,
    required Color surfaceColor,
    required Color borderColor,
  }) {
    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.center,
      children: [
        // Background subtle glow halo
        Positioned(
          right: -10,
          top: -10,
          child: Container(
            width: isDesktop ? 340 : 260,
            height: isDesktop ? 340 : 260,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isDarkMode
                  ? const Color(0x99281E1C)
                  : const Color(0xFFF5EBE6),
            ),
          ),
        ),

        // Main Image Frame
        ClipPath(
          clipper: StadiumCardClipper(),
          child: SizedBox(
            width: double.infinity,
            height: isDesktop ? 380 : 280,
            child: Image.network(
              'https://images.unsplash.com/photo-1533900298318-6b8da08a523e?q=80&w=1000&auto=format&fit=crop',
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  color: surfaceColor,
                  child: const Center(
                    child: Icon(
                      Icons.storefront_outlined,
                      size: 64,
                      color: AppColors.lightTextSecondary,
                    ),
                  ),
                );
              },
            ),
          ),
        ),

        // Top Right Badge Overlay: "8 min from you"
        Positioned(
          top: 16,
          right: 16,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: isDarkMode
                  ? const Color(0xFF131D2E).withValues(alpha: 0.92)
                  : Colors.white.withValues(alpha: 0.92),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: borderColor, width: 1),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 8,
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.near_me_rounded,
                  color: isDarkMode ? Colors.white : AppColors.lightTextPrimary,
                  size: 14,
                ),
                const SizedBox(width: 6),
                Text(
                  '8 min from you',
                  style: TextStyle(
                    color: isDarkMode
                        ? Colors.white
                        : AppColors.lightTextPrimary,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),

        // Bottom Left Floating Card: "Found nearby - 12 electronics shops"
        Positioned(
          bottom: 16,
          left: 12,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: isDarkMode
                  ? AppColors.darkSurface.withValues(alpha: 0.95)
                  : Colors.white.withValues(alpha: 0.95),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: borderColor, width: 1.2),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.12),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: AppColors.orange,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.search_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Found nearby',
                      style: TextStyle(
                        color: AppColors.lightTextSecondary,
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '12 electronics shops',
                      style: TextStyle(
                        color: isDarkMode
                            ? Colors.white
                            : AppColors.lightTextPrimary,
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 14),
                Container(
                  width: 7,
                  height: 7,
                  decoration: const BoxDecoration(
                    color: AppColors.green,
                    shape: BoxShape.circle,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// Custom Clipper to achieve the unique curved stadium card shape in the screenshot
class StadiumCardClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final Path path = Path();
    final double radius = size.height * 0.45;

    path.moveTo(radius, 0);
    path.lineTo(size.width - radius, 0);
    path.quadraticBezierTo(size.width, 0, size.width, radius);
    path.lineTo(size.width, size.height - radius);
    path.quadraticBezierTo(
      size.width,
      size.height,
      size.width - radius,
      size.height,
    );
    path.lineTo(radius, size.height);
    path.quadraticBezierTo(0, size.height, 0, size.height - radius);
    path.lineTo(0, radius);
    path.quadraticBezierTo(0, 0, radius, 0);
    path.close();

    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}
