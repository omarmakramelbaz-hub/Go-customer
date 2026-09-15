import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapController with ChangeNotifier {
  double? currentLat;
  double? currentLng;
  Set<Marker> markers = {};
  List<Placemark>? placemarks;
  bool isCheckingLocation = false;
  bool isMapInteracting = false;

  GoogleMapController? gmc;
  Timer? _debounce;

  Future<void> determinePosition() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        await Geolocator.openLocationSettings();
        serviceEnabled = await Geolocator.isLocationServiceEnabled();
        if (!serviceEnabled) {
          log('Location services are still disabled.');
          return;
        }
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.unableToDetermine ||
          permission == LocationPermission.deniedForever) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          log('Location permissions are denied');
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        log('Location permissions are permanently denied, we cannot request permissions.');
        return;
      }

      Position position = await Geolocator.getCurrentPosition();
      updateLocation(position.latitude, position.longitude);
    } catch (e) {
      log('Failed to get location: $e');
    }
  }

  void updateLocation(double lat, double lng) async {
    currentLat = lat;
    currentLng = lng;

    markers.clear();
    markers.add(Marker(markerId: const MarkerId('currentLocation'), position: LatLng(lat, lng)));

    if (gmc != null) {
      gmc!.animateCamera(CameraUpdate.newLatLng(LatLng(lat, lng)));
    }

    placemarks = await placemarkFromCoordinates(lat, lng);
    notifyListeners(); // Notify listeners that the state has changed
  }

  void onMapTap(LatLng latLng) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      updateLocation(latLng.latitude, latLng.longitude);
    });

    if (gmc != null) {
      gmc!.animateCamera(CameraUpdate.newLatLng(LatLng(latLng.latitude, latLng.longitude)));
    }

    markers.clear();
    markers.add(
      Marker(markerId: const MarkerId('currentLocation'), position: LatLng(latLng.latitude, latLng.longitude)),
    );

    notifyListeners(); // Notify listeners that the state has changed
  }

  void onMapInteractionStart() {
    isMapInteracting = true;
    notifyListeners();
  }

  void onMapInteractionEnd() {
    isMapInteracting = false;
    notifyListeners();
  }

  Future<void> recheckLocationServices() async {
    isCheckingLocation = true;
    notifyListeners();

    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (serviceEnabled) {
      await determinePosition(); // Recheck location if enabled
    } else {
      log('Location services are still disabled.');
    }

    isCheckingLocation = false;
    notifyListeners();
  }

  void setMapController(GoogleMapController controller) {
    gmc = controller;
    notifyListeners();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    gmc?.dispose();
    super.dispose();
  }
}
