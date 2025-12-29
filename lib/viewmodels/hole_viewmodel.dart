import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../models/club.dart';
import '../models/hole.dart';

enum HolePhase { waitingForTee, waitingForGreen, playing }

class HoleViewModel extends ChangeNotifier {
  final Hole hole = Hole();
  Position? position;
  HolePhase phase = HolePhase.waitingForTee;

  GoogleMapController? mapController;
  StreamSubscription<Position>? _positionStream;

  double windSpeed = 6.0;

  final List<Club> clubs = [
    Club("Driver", 220),
    Club("7 Iron", 140),
    Club("PW", 100),
  ];

  /// START GPS
  Future<void> startTracking() async {
    bool enabled = await Geolocator.isLocationServiceEnabled();
    if (!enabled) return;

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    _positionStream = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 3,
      ),
    ).listen((pos) {
      position = pos;
      notifyListeners();

      if (mapController != null && phase == HolePhase.waitingForTee) {
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

  /// ACTIONS
  void setTee() {
    if (position == null) return;
    hole.tee = LatLng(position!.latitude, position!.longitude);
    phase = HolePhase.waitingForGreen;
    notifyListeners();
  }

  void setGreen(LatLng point) {
    if (phase != HolePhase.waitingForGreen) return;
    hole.green = point;
    phase = HolePhase.playing;
    notifyListeners();
  }

  void resetHole() {
    hole.tee = null;
    hole.green = null;
    phase = HolePhase.waitingForTee;
    notifyListeners();
  }

  /// DATA
  double distanceToGreen() {
    if (position == null || hole.green == null) return 0;
    return Geolocator.distanceBetween(
      position!.latitude,
      position!.longitude,
      hole.green!.latitude,
      hole.green!.longitude,
    );
  }

  Club get recommendedClub {
    final d = distanceToGreen() + (windSpeed * 4);
    return clubs.firstWhere(
          (c) => c.maxDistance >= d,
      orElse: () => clubs.last,
    );
  }

  String get actionText {
    switch (phase) {
      case HolePhase.waitingForTee:
        return "Sätt tee (din position)";
      case HolePhase.waitingForGreen:
        return "Tryck på kartan för green";
      case HolePhase.playing:
        return "Avsluta hål";
    }
  }

  @override
  void dispose() {
    _positionStream?.cancel();
    super.dispose();
  }
}
