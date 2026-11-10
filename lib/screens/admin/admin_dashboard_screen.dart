import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final Color foreground = Theme.of(context).brightness == Brightness.dark
        ? AppColors.darkTextPrimary
        : AppColors.lightTextPrimary;
    final Color secondary = Theme.of(context).brightness == Brightness.dark
        ? AppColors.darkTextSecondary
        : AppColors.lightTextSecondary;

    return Scaffold(
      appBar: AppBar(title: const Text('Admin dashboard')),
      body: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        initialData: FirebaseAuth.instance.currentUser,
        builder: (BuildContext context, AsyncSnapshot<User?> authSnapshot) {
          final User? user = authSnapshot.data;
          if (user == null) {
            return const _AccessMessage(
              icon: Icons.login,
              title: 'Sign in required',
              message: 'Sign in with an admin account to open this dashboard.',
            );
          }

          return FutureBuilder<IdTokenResult>(
            future: user.getIdTokenResult(true),
            builder:
                (
                  BuildContext context,
                  AsyncSnapshot<IdTokenResult> claimSnapshot,
                ) {
                  if (claimSnapshot.hasError) {
                    return _AccessMessage(
                      icon: Icons.error_outline,
                      title: 'Could not verify admin access',
                      message: '${claimSnapshot.error}',
                    );
                  }
                  if (!claimSnapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (claimSnapshot.data!.claims?['role'] != 'admin') {
                    return const _AccessMessage(
                      icon: Icons.lock_outline,
                      title: 'Admin access only',
                      message: 'This account does not have the role=admin permission.',
                    );
                  }

                  return LayoutBuilder(
                    builder:
                        (BuildContext context, BoxConstraints constraints) {
                          final int columns = constraints.maxWidth >= 1000
                              ? 3
                              : constraints.maxWidth >= 640
                              ? 2
                              : 1;
                          return ListView(
                            padding: const EdgeInsets.all(24),
                            children: [
                              Text(
                                'Seller oversight',
                                style: Theme.of(context).textTheme.headlineSmall
                                    ?.copyWith(
                                      color: foreground,
                                      fontWeight: FontWeight.w700,
                                    ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Review seller accounts, their activity, and their product listings.',
                                style: TextStyle(color: secondary),
                              ),
                              const SizedBox(height: 24),
                              GridView.count(
                                crossAxisCount: columns,
                                crossAxisSpacing: 16,
                                mainAxisSpacing: 16,
                                childAspectRatio: columns == 1 ? 1.4 : 1.15,
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                children: const [
                                  _DashboardSection(
                                    icon: Icons.storefront_outlined,
                                    title: 'Sellers',
                                    description: 'Seller accounts and their approval status will appear here.',
                                  ),
                                  _DashboardSection(
                                    icon: Icons.history,
                                    title: 'Seller activity',
                                    description: 'Product and shop changes will appear here when activity data is connected.',
                                  ),
                                  _DashboardSection(
                                    icon: Icons.inventory_2_outlined,
                                    title: 'Products by seller',
                                    description: 'Seller product listings will appear here when the admin data source is connected.',
                                  ),
                                ],
                              ),
                              const SizedBox(height: 20),
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: AppColors.orange.withValues(
                                    alpha: 0.1,
                                  ),
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(
                                    color: AppColors.orange.withValues(
                                      alpha: 0.4,
                                    ),
                                  ),
                                ),
                                child: const Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Icon(
                                      Icons.info_outline,
                                      color: AppColors.orange,
                                    ),
                                    SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        'Dashboard data is not connected yet. Add admin-protected backend endpoints for sellers, activity, and seller products to populate these sections.',
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          );
                        },
                  );
                },
          );
        },
      ),
    );
  }
}

class _DashboardSection extends StatelessWidget {
  const _DashboardSection({
    required this.icon,
    required this.title,
    required this.description,
  });

  final IconData icon;
  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color secondary = isDark
        ? AppColors.darkTextSecondary
        : AppColors.lightTextSecondary;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: AppColors.orange, size: 28),
            const SizedBox(height: 12),
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium
                  ?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: Text(
                description,
                style: TextStyle(color: secondary, height: 1.4),
              ),
            ),
            const SizedBox(height: 8),
            const Chip(
              avatar: Icon(Icons.link_off, size: 16),
              label: Text('Backend not connected'),
              visualDensity: VisualDensity.compact,
            ),
          ],
        ),
      ),
    );
  }
}

class _AccessMessage extends StatelessWidget {
  const _AccessMessage({
    required this.icon,
    required this.title,
    required this.message,
  });

  final IconData icon;
  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color secondary = isDark
        ? AppColors.darkTextSecondary
        : AppColors.lightTextSecondary;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 48, color: AppColors.orange),
              const SizedBox(height: 16),
              Text(
                title,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              Text(
                message,
                textAlign: TextAlign.center,
                style: TextStyle(color: secondary),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
