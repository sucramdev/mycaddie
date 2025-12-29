import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../models/club.dart';

class MapViewModel extends ChangeNotifier {
  Position? position;
  LatLng? aimPoint;

  final List<Club> clubs = [
    Club("Driver", 220),
    Club("7 Iron", 140),
    Club("PW", 100),
  ];

  Future<void> updatePosition() async {
    position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
    notifyListeners();
  }

  void setAim(LatLng point) {
    aimPoint = point;
    notifyListeners();
  }

  double? distanceToAim() {
    if (position == null || aimPoint == null) return null;
    return Geolocator.distanceBetween(
      position!.latitude,
      position!.longitude,
      aimPoint!.latitude,
      aimPoint!.longitude,
    );
  }

  Club? recommendedClub() {
    final d = distanceToAim();
    if (d == null) return null;
    return clubs.firstWhere(
          (c) => c.maxDistance >= d,
      orElse: () => clubs.last,
    );
  }
}
