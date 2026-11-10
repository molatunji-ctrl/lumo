import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../core/routing/app_router.dart';
import '../../core/theme/app_colors.dart';
import '../../models/product.dart';
import '../../services/product_service.dart';
import '../../widgets/app_bottom_navigation.dart';
import '../../widgets/product_favorite_button.dart';

class FavouritesScreen extends StatelessWidget {
  const FavouritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final User? user = FirebaseAuth.instance.currentUser;
    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      appBar: AppBar(title: const Text('Favourites')),
      body: user == null
          ? _FavouritesMessage(
              message: 'Sign in to save products and see your favourites here.',
              action: TextButton(
                onPressed: () =>
                    Navigator.pushNamed(context, AppRouter.account),
                child: const Text('Sign in'),
              ),
            )
          : StreamBuilder<List<Product>>(
              stream: ProductService().watchFavourites(user.uid),
              builder:
                  (
                    BuildContext context,
                    AsyncSnapshot<List<Product>> snapshot,
                  ) {
                    if (snapshot.hasError) {
                      return _FavouritesMessage(
                        message: 'Could not load favourites: ${snapshot.error}',
                      );
                    }
                    if (!snapshot.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    final List<Product> products = snapshot.data!;
                    if (products.isEmpty) {
                      return const _FavouritesMessage(
                        icon: Icons.favorite_border,
                        message: 'You have not saved any products yet.',
                      );
                    }
                    return ListView.separated(
                      padding: const EdgeInsets.all(16),
                      itemCount: products.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 10),
                      itemBuilder: (BuildContext context, int index) {
                        final Product product = products[index];
                        return Card(
                          child: ListTile(
                            onTap: () => Navigator.pushNamed(
                              context,
                              AppRouter.productDetails,
                              arguments: product,
                            ),
                            leading: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(
                                product.imageUrl,
                                width: 58,
                                height: 58,
                                fit: BoxFit.cover,
                                errorBuilder: (_, _, _) => const SizedBox(
                                  width: 58,
                                  height: 58,
                                  child: Icon(
                                    Icons.image_not_supported_outlined,
                                  ),
                                ),
                              ),
                            ),
                            title: Text(product.name),
                            subtitle: Text(
                              '${product.shopName} · ${product.displayPrice}',
                            ),
                            trailing: ProductFavoriteButton(
                              product: product,
                              iconColor: AppColors.orange,
                            ),
                          ),
                        );
                      },
                    );
                  },
            ),
      bottomNavigationBar: AppBottomNavigation(
        currentIndex: 3,
        onTap: (int index) {
          final String? route = switch (index) {
            0 => AppRouter.home,
            1 => AppRouter.search,
            2 => AppRouter.nearby,
            4 => AppRouter.account,
            _ => null,
          };
          if (route != null) Navigator.pushReplacementNamed(context, route);
        },
      ),
    );
  }
}

class _FavouritesMessage extends StatelessWidget {
  const _FavouritesMessage({
    required this.message,
    this.icon = Icons.cloud_off_outlined,
    this.action,
  });

  final String message;
  final IconData icon;
  final Widget? action;

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(28),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 56, color: AppColors.textMuted),
          const SizedBox(height: 12),
          Text(message, textAlign: TextAlign.center),
          ?action,
        ],
      ),
    ),
  );
}
