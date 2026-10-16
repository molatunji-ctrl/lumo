import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../widgets/app_bottom_navigation.dart';
import '../../core/routing/app_router.dart';

class AccountScreen extends StatelessWidget {
  const AccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Account'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushReplacementNamed(context, AppRouter.home);
          },
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.cardBorder),
              ),
              child: const Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: AppColors.navy,
                    child: Icon(Icons.person, size: 36, color: Colors.white),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Alex Johnson',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'alex.johnson@example.com',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            _buildOptionTile(
              icon: Icons.shopping_bag_outlined,
              title: 'My Orders',
              onTap: () {},
            ),
            _buildOptionTile(
              icon: Icons.location_on_outlined,
              title: 'Saved Locations',
              onTap: () {},
            ),
            _buildOptionTile(
              icon: Icons.notifications_outlined,
              title: 'Notification Settings',
              onTap: () {},
            ),
            _buildOptionTile(
              icon: Icons.help_outline,
              title: 'Support & FAQ',
              onTap: () {},
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.error,
                  side: const BorderSide(color: AppColors.error),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () {},
                child: const Text('Log Out'),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: AppBottomNavigation(
        currentIndex: 4,
        onTap: (index) {
          if (index == 4) return;
          if (index == 0) Navigator.pushReplacementNamed(context, AppRouter.home);
          if (index == 1) Navigator.pushReplacementNamed(context, AppRouter.search);
          if (index == 2) Navigator.pushReplacementNamed(context, AppRouter.markets);
          if (index == 3) Navigator.pushReplacementNamed(context, AppRouter.favourites);
        },
      ),
    );
  }

  Widget _buildOptionTile({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: ListTile(
        leading: Icon(icon, color: AppColors.navy),
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w500,
            color: AppColors.textPrimary,
          ),
        ),
        trailing: const Icon(Icons.chevron_right, color: AppColors.textMuted),
        onTap: onTap,
      ),
    );
  }
}
