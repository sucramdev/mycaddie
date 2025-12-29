import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../models/club.dart';

class MapController extends ChangeNotifier {
  Position? position;
  LatLng? green;
  bool selectingHole = false;

  GoogleMapController? mapController;
  StreamSubscription<Position>? _sub;

  final List<Club> clubs = [
    Club("Driver", 220),
    Club("7 Iron", 140),
    Club("PW", 100),
  ];

  final double windSpeed = 6.0; // m/s (mock)

  void startTracking() {
    _sub = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 2,
      ),
    ).listen((pos) {
      position = pos;

      // hoppa till GPS första gången
      if (mapController != null) {
        mapController!.animateCamera(
          CameraUpdate.newLatLngZoom(
            LatLng(pos.latitude, pos.longitude),
            17,
          ),
        );
      }

      notifyListeners();
    });
  }

  void stopTracking() {
    _sub?.cancel();
  }

  void setMapController(GoogleMapController controller) {
    mapController = controller;
  }

  void startSelectHole() {
    selectingHole = true;
    notifyListeners();
  }

  void setHole(LatLng point) {
    green = point;
    selectingHole = false;
    notifyListeners();
  }

  double distanceToGreen() {
    if (position == null || green == null) return 0;
    return Geolocator.distanceBetween(
      position!.latitude,
      position!.longitude,
      green!.latitude,
      green!.longitude,
    );
  }

  double adjustedDistance() {
    return distanceToGreen() + windSpeed * 4;
  }

  Club recommendedClub() {
    return clubs.firstWhere(
          (c) => c.maxDistance >= adjustedDistance(),
      orElse: () => clubs.last,
    );
  }
}
