import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'notification_service.dart';

class LocationService {
  static final LocationService _instance = LocationService._internal();
  factory LocationService() => _instance;
  LocationService._internal();

  final NotificationService _notificationService = NotificationService();

  Future<bool> requestLocationPermission() async {
    final permission = await Permission.location.request();
    return permission.isGranted;
  }

  Future<Position?> getCurrentLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return null;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          return null;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        return null;
      }

      return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
    } catch (e) {
      print('Error obteniendo ubicación: $e');
      return null;
    }
  }

  double calculateDistance(
    double lat1, double lon1,
    double lat2, double lon2,
  ) {
    return Geolocator.distanceBetween(lat1, lon1, lat2, lon2);
  }

  Future<void> checkNearbyStores({
    required double userLat,
    required double userLon,
    required List<Map<String, dynamic>> storeLocations,
    double radiusInMeters = 500,
  }) async {
    for (var store in storeLocations) {
      double distance = calculateDistance(
        userLat, userLon,
        store['latitude'], store['longitude'],
      );

      if (distance <= radiusInMeters) {
        await _notificationService.showLocationReminder(
          title: '🏪 ¡Estás cerca de ${store['name']}!',
          body: 'Tienes una lista de compras pendiente para este lugar',
          payload: 'store_nearby_${store['listId']}',
        );
      }
    }
  }

  Stream<Position> getLocationStream() {
    const locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 100, // Solo actualizar cada 100 metros
    );
    
    return Geolocator.getPositionStream(locationSettings: locationSettings);
  }
}