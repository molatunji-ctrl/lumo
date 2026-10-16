import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

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

    return Container(
      color: AppColors.darkBackground,
      padding: EdgeInsets.symmetric(
        horizontal: isDesktop ? 48 : 20,
        vertical: 16,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Logo
          const Text(
            'lumo',
            style: TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.w900,
              letterSpacing: -1.5,
            ),
          ),

          // Nav links for Desktop
          if (isDesktop)
            Row(
              children: [
                _buildNavLink('Discover', isActive: true, onTap: () {}),
                const SizedBox(width: 24),
                _buildNavLink('Products', onTap: () {}),
                const SizedBox(width: 24),
                _buildNavLink('Markets', onTap: () {}),
                const SizedBox(width: 24),
                _buildNavLink('Nearby shops', onTap: () {}),
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
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.cardBorder),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.location_on_outlined,
                        color: AppColors.textSecondary,
                        size: 16,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        locationName,
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(
                        Icons.keyboard_arrow_down,
                        color: AppColors.textSecondary,
                        size: 16,
                      ),
                    ],
                  ),
                ),
              ),

              if (isDesktop) ...[
                const SizedBox(width: 12),
                // Theme Toggle Icon
                _buildIconButton(
                  icon: Icons.light_mode_outlined,
                  onTap: () {},
                ),
              ],

              const SizedBox(width: 8),

              // Notification Icon
              _buildIconButton(
                icon: Icons.notifications_none_rounded,
                onTap: onNotificationTap ?? () {},
              ),

              if (isDesktop) ...[
                const SizedBox(width: 12),
                // Sign In Button
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.cardBorder),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.person_outline_rounded,
                        color: AppColors.textPrimary,
                        size: 16,
                      ),
                      SizedBox(width: 6),
                      Text(
                        'Sign in',
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNavLink(String title,
      {bool isActive = false, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Text(
        title,
        style: TextStyle(
          color: isActive ? Colors.white : AppColors.textSecondary,
          fontSize: 14,
          fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildIconButton({required IconData icon, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: AppColors.surface,
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.cardBorder),
        ),
        child: Icon(
          icon,
          color: AppColors.textPrimary,
          size: 18,
        ),
      ),
    );
  }
}
