import 'package:flutter/material.dart';

import '../../models/product.dart';
import '../../models/shop.dart';

import '../../screens/splash/splash_screen.dart';
import '../../screens/home/home_screen.dart';
import '../../screens/search/search_screen.dart';
import '../../screens/products/products_screen.dart';
import '../../screens/products/product_details_screen.dart';
import '../../screens/shops/shop_details_screen.dart';
import '../../screens/markets/markets_screen.dart';
import '../../screens/nearby/nearby_shops_screen.dart';
import '../../screens/favourites/favourites_screen.dart';
import '../../screens/account/account_screen.dart';

class AppRouter {
  AppRouter._();

  static const String splash = '/';
  static const String home = '/home';
  static const String search = '/search';
  static const String products = '/products';
  static const String productDetails = '/product-details';
  static const String shopDetails = '/shop-details';
  static const String markets = '/markets';
  static const String nearby = '/nearby';
  static const String favourites = '/favourites';
  static const String account = '/account';

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case splash:
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (_) => const SplashScreen(),
        );

      case home:
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (_) => const HomeScreen(),
        );

      case search:
        final query = settings.arguments as String?;
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (_) => SearchScreen(initialQuery: query),
        );

      case products:
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (_) => const ProductsScreen(),
        );

      case productDetails:
        final Object? arguments = settings.arguments;

        if (arguments is! Product) {
          return _errorRoute(
            settings,
            'Invalid product',
            'Product details require a valid Product object.',
          );
        }

        return MaterialPageRoute<void>(
          settings: settings,
          builder: (_) => ProductDetailsScreen(product: arguments),
        );

      case shopDetails:
        final Object? arguments = settings.arguments;

        if (arguments is! Shop) {
          return _errorRoute(
            settings,
            'Invalid shop',
            'Shop details require a valid Shop object.',
          );
        }

        return MaterialPageRoute<void>(
          settings: settings,
          builder: (_) => ShopDetailsScreen(shop: arguments),
        );

      case markets:
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (_) => const MarketsScreen(),
        );

      case nearby:
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (_) => const NearbyShopsScreen(),
        );

      case favourites:
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (_) => const FavouritesScreen(),
        );

      case account:
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (_) => const AccountScreen(),
        );

      default:
        return _errorRoute(
          settings,
          'Page not found',
          'The requested page "${settings.name ?? ''}" does not exist.',
        );
    }
  }

  static MaterialPageRoute<void> _errorRoute(
    RouteSettings settings,
    String title,
    String message,
  ) {
    return MaterialPageRoute<void>(
      settings: settings,
      builder: (context) => Scaffold(
        appBar: AppBar(title: Text(title)),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.warning_amber_rounded, size: 48),
                const SizedBox(height: 16),
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleLarge,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(message, textAlign: TextAlign.center),
                const SizedBox(height: 24),
                FilledButton(
                  onPressed: () {
                    Navigator.pushNamedAndRemoveUntil(
                      context,
                      home,
                      (route) => false,
                    );
                  },
                  child: const Text('Return to home'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
