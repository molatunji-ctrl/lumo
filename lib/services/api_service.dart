import '../models/product.dart';
import '../models/shop.dart';
import '../models/market.dart';

class ApiService {
  // Simulates network latency
  Future<void> _delay() async {
    await Future.delayed(const Duration(milliseconds: 600));
  }

  Future<List<Product>> getProducts() async {
    await _delay();
    return Product.mockProducts;
  }

  Future<List<Shop>> getShops() async {
    await _delay();
    return Shop.mockShops;
  }

  Future<List<Market>> getMarkets() async {
    await _delay();
    return Market.mockMarkets;
  }

  Future<List<Shop>> searchShops(String query) async {
    await _delay();
    if (query.isEmpty) return Shop.mockShops;
    return Shop.mockShops
        .where((s) => s.name.toLowerCase().contains(query.toLowerCase()) ||
            s.description.toLowerCase().contains(query.toLowerCase()))
        .toList();
  }
}
