import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../models/club.dart';
import '../models/hole.dart';

enum HolePhase { waitingForTee, waitingForGreen, playing }

class MapViewModel extends ChangeNotifier {
  Position? position;
  GoogleMapController? mapController;

  final Hole hole = Hole();
  HolePhase phase = HolePhase.waitingForTee;

  final double windSpeed = 6.0; // mockad vind

  final List<Club> clubs = [
    Club("PW", 100),
    Club("7 Iron", 140),
    Club("Driver", 220),
  ];

  StreamSubscription<Position>? _sub;

  Future<void> startTracking() async {
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

  void onMapTap(LatLng point) {
    if (phase == HolePhase.waitingForTee) {
      hole.tee = point;
      phase = HolePhase.waitingForGreen;
    } else if (phase == HolePhase.waitingForGreen) {
      hole.green = point;
      phase = HolePhase.playing;
    }
    notifyListeners();
  }

  double get distanceToGreen {
    if (position == null || hole.green == null) return 0;
    return Geolocator.distanceBetween(
      position!.latitude,
      position!.longitude,
      hole.green!.latitude,
      hole.green!.longitude,
    );
  }

  Club get recommendedClub {
    final adjusted = distanceToGreen + windSpeed * 4;
    return clubs.firstWhere(
          (c) => c.maxDistance >= adjusted,
      orElse: () => clubs.last,
    );
  }

  void resetHole() {
    hole.tee = null;
    hole.green = null;
    phase = HolePhase.waitingForTee;
    notifyListeners();
  }
}
