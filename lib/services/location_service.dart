import 'package:geolocator/geolocator.dart';

class LocationService {
  Future<Position> getCurrentPosition() async {
    if (!await Geolocator.isLocationServiceEnabled()) {
      throw StateError('Turn on device location services and try again.');
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.denied) {
      throw StateError('Location permission was denied.');
    }
    if (permission == LocationPermission.deniedForever) {
      throw StateError(
        'Location permission is disabled for Lumo. Enable it in system settings.',
      );
    }

    return Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        timeLimit: Duration(seconds: 20),
      ),
    );
  }

  double calculateDistanceInKm(
    double startLat,
    double startLng,
    double endLat,
    double endLng,
  ) {
    return Geolocator.distanceBetween(startLat, startLng, endLat, endLng) /
        1000;
  }
}
