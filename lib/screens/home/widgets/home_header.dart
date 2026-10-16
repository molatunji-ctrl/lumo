import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../app.dart';
import '../../../core/routing/app_router.dart';

class HomeHeader extends StatelessWidget {
  final String locationName;
  final VoidCallback? onLocationTap;
  final VoidCallback? onNotificationTap;

  const HomeHeader({
    super.key,
    this.locationName = 'Ikeja, Lagos',
    this.onLocationTap,
    this.onNotificationTap,
  });

  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.of(context).size.width;
    final bool isDesktop = width > 800;
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    final Color bgColor = isDarkMode ? AppColors.darkBackground : AppColors.lightBackground;
    final Color textColor = isDarkMode ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final Color surfaceColor = isDarkMode ? AppColors.darkSurface : AppColors.lightSurface;
    final Color borderColor = isDarkMode ? AppColors.darkCardBorder : AppColors.lightCardBorder;
    final Color secondaryColor = isDarkMode ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;

    return Container(
      color: bgColor,
      padding: EdgeInsets.symmetric(
        horizontal: isDesktop ? 48 : 20,
        vertical: 16,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Logo
          Text(
            'lumo',
            style: TextStyle(
              color: textColor,
              fontSize: 28,
              fontWeight: FontWeight.w900,
              letterSpacing: -1.5,
            ),
          ),

          // Nav links for Desktop
          if (isDesktop)
            Row(
              children: [
                _buildNavLink('Discover', isActive: true, textColor: textColor, secondaryColor: secondaryColor, onTap: () {}),
                const SizedBox(width: 24),
                _buildNavLink('Products', textColor: textColor, secondaryColor: secondaryColor, onTap: () {
                  Navigator.pushNamed(context, AppRouter.products);
                }),
                const SizedBox(width: 24),
                _buildNavLink('Markets', textColor: textColor, secondaryColor: secondaryColor, onTap: () {
                  Navigator.pushNamed(context, AppRouter.markets);
                }),
                const SizedBox(width: 24),
                _buildNavLink('Nearby shops', textColor: textColor, secondaryColor: secondaryColor, onTap: () {
                  Navigator.pushNamed(context, AppRouter.nearby);
                }),
              ],
            ),

          // Right action buttons
          Row(
            children: [
              // Location Dropdown Pill
              GestureDetector(
                onTap: onLocationTap,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: surfaceColor,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: borderColor),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.location_on_outlined,
                        color: secondaryColor,
                        size: 16,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        locationName,
                        style: TextStyle(
                          color: textColor,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(
                        Icons.keyboard_arrow_down,
                        color: secondaryColor,
                        size: 16,
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(width: 8),

              // Theme Toggle Icon Button
              _buildIconButton(
                icon: isDarkMode ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
                surfaceColor: surfaceColor,
                borderColor: borderColor,
                iconColor: textColor,
                onTap: () {
                  ThemeController.instance.toggleTheme();
                },
              ),

              const SizedBox(width: 8),

              // Notification Icon
              _buildIconButton(
                icon: Icons.notifications_none_rounded,
                surfaceColor: surfaceColor,
                borderColor: borderColor,
                iconColor: textColor,
                onTap: onNotificationTap ?? () {},
              ),

              if (isDesktop) ...[
                const SizedBox(width: 12),
                // Sign In Button
                GestureDetector(
                  onTap: () {
                    Navigator.pushNamed(context, AppRouter.account);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: surfaceColor,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: borderColor),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.person_outline_rounded,
                          color: textColor,
                          size: 16,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Sign in',
                          style: TextStyle(
                            color: textColor,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNavLink(
    String title, {
    bool isActive = false,
    required Color textColor,
    required Color secondaryColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Text(
        title,
        style: TextStyle(
          color: isActive ? textColor : secondaryColor,
          fontSize: 14,
          fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildIconButton({
    required IconData icon,
    required Color surfaceColor,
    required Color borderColor,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: surfaceColor,
          shape: BoxShape.circle,
          border: Border.all(color: borderColor),
        ),
        child: Icon(
          icon,
          color: iconColor,
          size: 18,
        ),
      ),
    );
  }
}
// Header widget
