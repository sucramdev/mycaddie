import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../models/club.dart';

enum MapPhase {
  waitingForTee,
  waitingForGreen,
  ready,
}

class MapViewModel extends ChangeNotifier {
  Position? position;
  GoogleMapController? mapController;

  LatLng? tee;
  LatLng? green;

  MapPhase phase = MapPhase.waitingForTee;

  final double windSpeed = 6.0; // mockad vind

  final List<Club> clubs = [
    Club("PW", 100),
    Club("7 Iron", 140),
    Club("Driver", 220),
  ];

  StreamSubscription<Position>? _sub;

  /// Startar GPS + följer användaren
  Future<void> startTracking() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return;

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    _sub = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 3,
      ),
    ).listen((pos) {
      position = pos;
      notifyListeners();

      if (mapController != null) {
        mapController!.animateCamera(
          CameraUpdate.newLatLng(
            LatLng(pos.latitude, pos.longitude),
          ),
        );
      }
    });
  }

  void onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  /// Sätt tee = din nuvarande position
  void setTee() {
    if (position == null) return;

    tee = LatLng(position!.latitude, position!.longitude);
    phase = MapPhase.waitingForGreen;
    notifyListeners();
  }

  /// Klick på karta – används bara för green
  void onMapTap(LatLng point) {
    if (phase != MapPhase.waitingForGreen) return;

    green = point;
    phase = MapPhase.ready;
    notifyListeners();
  }

  /// Flytta green igen
  void resetGreen() {
    green = null;
    phase = MapPhase.waitingForGreen;
    notifyListeners();
  }

  double get distanceToGreen {
    if (position == null || green == null) return 0;
    return Geolocator.distanceBetween(
      position!.latitude,
      position!.longitude,
      green!.latitude,
      green!.longitude,
    );
  }

  Club get recommendedClub {
    return clubs.firstWhere(
          (c) => c.maxDistance >= distanceToGreen,
      orElse: () => clubs.last,
    );
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}
