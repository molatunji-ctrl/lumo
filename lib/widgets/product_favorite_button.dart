import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../core/routing/app_router.dart';
import '../core/theme/app_colors.dart';
import '../models/product.dart';
import '../services/product_service.dart';

class ProductFavoriteButton extends StatelessWidget {
  const ProductFavoriteButton({
    required this.product,
    this.backgroundColor = Colors.white,
    this.iconColor = Colors.black,
    this.iconSize = 20,
    this.onChanged,
    super.key,
  });

  final Product product;
  final Color backgroundColor;
  final Color iconColor;
  final double iconSize;
  final VoidCallback? onChanged;

  @override
  Widget build(BuildContext context) {
    final User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return IconButton(
        tooltip: 'Sign in to save this product',
        icon: Icon(Icons.favorite_border, color: iconColor, size: iconSize),
        onPressed: () => Navigator.pushNamed(context, AppRouter.account),
      );
    }

    return StreamBuilder<bool>(
      stream: ProductService().watchIsFavourite(user.uid, product.id),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return IconButton(
            tooltip: 'Could not load favourite status',
            icon: Icon(Icons.error_outline, color: iconColor, size: iconSize),
            onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Could not load favourite status: ${snapshot.error}',
                ),
              ),
            ),
          );
        }
        final bool isFavourite = snapshot.data ?? false;
        return IconButton(
          tooltip: isFavourite
              ? 'Remove from favourites'
              : 'Save to favourites',
          style: IconButton.styleFrom(backgroundColor: backgroundColor),
          icon: Icon(
            isFavourite ? Icons.favorite : Icons.favorite_border,
            color: isFavourite ? AppColors.orange : iconColor,
            size: iconSize,
          ),
          onPressed: snapshot.connectionState == ConnectionState.waiting
              ? null
              : () async {
                  try {
                    await ProductService().setFavourite(product, !isFavourite);
                    onChanged?.call();
                  } catch (error) {
                    if (!context.mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Could not update favourite: $error'),
                      ),
                    );
                  }
                },
        );
      },
    );
  }
}
