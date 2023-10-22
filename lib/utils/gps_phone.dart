import 'package:geolocator/geolocator.dart';

class UserGPS {
  final GeolocatorPlatform _geolocator = GeolocatorPlatform.instance;

  Future<Position> getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;
    Position position;

    // Check if location services are enabled
    serviceEnabled = await _geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('Location services are disabled.');
    }

    // Check if the app has location permissions
    permission = await _geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await _geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Location permissions are denied.');
      }
    }

    // Get the current position
    position = await _geolocator.getCurrentPosition();
    return position;
  }
}
