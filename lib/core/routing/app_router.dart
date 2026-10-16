import 'package:flutter/material.dart';
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
import '../../models/shop.dart';

class AppRouter {
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
        return MaterialPageRoute(builder: (_) => const SplashScreen());
      case home:
        return MaterialPageRoute(builder: (_) => const HomeScreen());
      case search:
        return MaterialPageRoute(builder: (_) => const SearchScreen());
      case products:
        return MaterialPageRoute(builder: (_) => const ProductsScreen());
      case productDetails:
        return MaterialPageRoute(
          builder: (_) => ProductDetailsScreen(item: settings.arguments),
        );
      case shopDetails:
        return MaterialPageRoute(
          builder: (_) => ShopDetailsScreen(shop: settings.arguments as Shop?),
        );
      case markets:
        return MaterialPageRoute(builder: (_) => const MarketsScreen());
      case nearby:
        return MaterialPageRoute(builder: (_) => const NearbyShopsScreen());
      case favourites:
        return MaterialPageRoute(builder: (_) => const FavouritesScreen());
      case account:
        return MaterialPageRoute(builder: (_) => const AccountScreen());
      default:
        return MaterialPageRoute(builder: (_) => const HomeScreen());
    }
  }
}
