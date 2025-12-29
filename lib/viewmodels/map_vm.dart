import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../models/club.dart';
import '../models/hole.dart';

class MapViewModel extends ChangeNotifier {
  Position? position;
  LatLng? aimPoint;

  GoogleMapController? mapController;

  double windSpeed = 6.0; // mockad vind

  final Hole currentHole = Hole(
    number: 1,
    tee: const LatLng(59.3290, 18.0682),
    green: const LatLng(59.3296, 18.0695),
  );

  final List<Club> clubs = [
    Club("Driver", 220),
    Club("7 Iron", 140),
    Club("PW", 100),
  ];

  StreamSubscription<Position>? _positionStream;

  void onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  Future<void> startTracking() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return;

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    _positionStream = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.bestForNavigation,
        distanceFilter: 2,
      ),
    ).listen((pos) {
      position = pos;

      // 🔥 FLYTTA KAMERAN TILL DIN POSITION
      mapController?.animateCamera(
        CameraUpdate.newLatLng(
          LatLng(pos.latitude, pos.longitude),
        ),
      );

      notifyListeners();
    });
  }

  void stopTracking() {
    _positionStream?.cancel();
  }

  void setAim(LatLng point) {
    aimPoint = point;
    notifyListeners();
  }

  double distanceToGreen() {
    if (position == null) return 0;
    return Geolocator.distanceBetween(
      position!.latitude,
      position!.longitude,
      currentHole.green.latitude,
      currentHole.green.longitude,
    );
  }

  double adjustedDistance() {
    return distanceToGreen() + (windSpeed * 4);
  }

  Club recommendedClub() {
    return clubs.firstWhere(
          (c) => c.maxDistance >= adjustedDistance(),
      orElse: () => clubs.last,
    );
  }
}
