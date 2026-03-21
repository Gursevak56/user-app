import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:food_delivery/common/globs.dart';

class LocationService {
  /// Fetches the current location and saves it to SharedPreferences.
  /// This should be called after permissions have been requested and granted.
  static Future<void> fetchAndSaveCurrentLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        debugPrint('Location services are disabled.');
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are typically requested in the view before calling this,
        // but we double-check here.
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          debugPrint('Location permissions are denied');
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        debugPrint(
            'Location permissions are permanently denied, we cannot request permissions.');
        return;
      }

      // When we reach here, permissions are granted and we can fetch the position.
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      debugPrint('Fetched Location: Lat: ${position.latitude}, Lng: ${position.longitude}');

      // Save to SharedPreferences using Globs
      Globs.udDoubleSet(position.latitude, Globs.userLat);
      Globs.udDoubleSet(position.longitude, Globs.userLng);

      // Perform reverse geocoding to get human-readable address
      await _fetchAndSaveAddress(position.latitude, position.longitude);

    } catch (e) {
      debugPrint("Error fetching location: $e");
    }
  }

  static Future<void> _fetchAndSaveAddress(double lat, double lng) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(lat, lng);
      if (placemarks.isNotEmpty) {
        Placemark place = placemarks.first;
        // Typically something like: "Locality, AdministrativeArea" -> "Roorkee, UP"
        String locality = place.locality ?? place.subLocality ?? "";
        String adminArea = place.administrativeArea ?? "";
        
        String address = [locality, adminArea].where((s) => s.isNotEmpty).join(", ");
        
        if (address.isEmpty && place.country != null) {
          address = place.country!;
        }

        if (address.isNotEmpty) {
          Globs.udStringSet(address, Globs.userAddress);
          debugPrint('Fetched Address: $address');
        }
      }
    } catch (e) {
      debugPrint("Error fetching address from coordinates: $e");
    }
  }
}
