import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

class LocationHelper {
  static Future<String?> getCurrentCity() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      print("Servicio de ubicación desactivado");
      return null;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        print("Permiso de ubicación denegado");
        return null;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      print("Permiso de ubicación denegado permanentemente");
      return null;
    }

    final position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    final placemarks = await placemarkFromCoordinates(
      position.latitude,
      position.longitude,
    );

    if (placemarks.isNotEmpty) {
      final city = placemarks.first.locality;
      print("Ciudad detectada: $city | Coordenadas: (${position.latitude}, ${position.longitude})");
      return city;
    }

    print("No se encontraron placemarks.");
    return null;
  }
}
