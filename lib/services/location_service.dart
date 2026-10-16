import '../models/shop.dart';

class LocationService {
  Future<String> getCurrentCity() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return 'Central City, Downtown';
  }

  Future<List<Shop>> getNearbyShops() async {
    await Future.delayed(const Duration(milliseconds: 400));
    return Shop.mockShops;
  }

  double calculateDistanceInKm(
    double startLat,
    double startLng,
    double endLat,
    double endLng,
  ) {
    // Stub distance calculation logic
    return 0.8;
  }
}
