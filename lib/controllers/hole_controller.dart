import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../models/club.dart';
import '../models/hole.dart';

enum HolePhase {
  waitingForTee,
  waitingForGreen,
  playing,
}

class HoleController extends ChangeNotifier {
  GoogleMapController? mapController;
  StreamSubscription<Position>? _positionStream;

  Position? position;
  HolePhase phase = HolePhase.waitingForTee;

  final Hole hole = Hole();

  double windSpeed = 6.0; // mockad vind

  final List<Club> clubs = [
    Club("PW", 100),
    Club("7 Iron", 140),
    Club("Driver", 220),
  ];

  // =========================
  // MAP CALLBACK
  // =========================
  void onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  // =========================
  // GPS TRACKING
  // =========================
  Future<void> startTracking() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return;

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

      // zooma till användaren första gången
      mapController?.animateCamera(
        CameraUpdate.newLatLng(
          LatLng(pos.latitude, pos.longitude),
        ),
      );

      notifyListeners();
    });
  }

  // =========================
  // TAP PÅ KARTAN
  // =========================
  void onMapTap(LatLng point) {
    if (phase == HolePhase.waitingForGreen) {
      hole.green = point;
      phase = HolePhase.playing;
      notifyListeners();
    }
  }

  // =========================
  // ACTION-KNAPP
  // =========================
  void setTee() {
    if (position == null) return;

    hole.tee = LatLng(position!.latitude, position!.longitude);
    phase = HolePhase.waitingForGreen;
    notifyListeners();
  }

  void resetHole() {
    hole.tee = null;
    hole.green = null;
    phase = HolePhase.waitingForTee;
    notifyListeners();
  }

  // =========================
  // MARKERS
  // =========================
  Set<Marker> get markers {
    final Set<Marker> m = {};

    if (hole.tee != null) {
      m.add(
        Marker(
          markerId: const MarkerId("tee"),
          position: hole.tee!,
          icon: BitmapDescriptor.defaultMarkerWithHue(
            BitmapDescriptor.hueBlue,
          ),
          infoWindow: const InfoWindow(title: "Tee"),
        ),
      );
    }

    if (hole.green != null) {
      m.add(
        Marker(
          markerId: const MarkerId("green"),
          position: hole.green!,
          icon: BitmapDescriptor.defaultMarkerWithHue(
            BitmapDescriptor.hueRed,
          ),
          infoWindow: const InfoWindow(title: "Green"),
        ),
      );
    }

    return m;
  }

  // =========================
  // BEREKNINGAR
  // =========================
  double get distanceToGreen {
    if (position == null || hole.green == null) return 0;

    return Geolocator.distanceBetween(
      position!.latitude,
      position!.longitude,
      hole.green!.latitude,
      hole.green!.longitude,
    );
  }

  double get adjustedDistance {
    return distanceToGreen + (windSpeed * 4);
  }

  Club get recommendedClub {
    return clubs.firstWhere(
          (c) => c.maxDistance >= adjustedDistance,
      orElse: () => clubs.last,
    );
  }

  @override
  void dispose() {
    _positionStream?.cancel();
    super.dispose();
  }
}
