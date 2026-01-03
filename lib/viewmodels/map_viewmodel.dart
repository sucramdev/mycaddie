import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../models/club.dart';

enum MapState {
  WAITING_FOR_CURRENT_POSITION,
  WAITING_FOR_GREEN,
  WAITING_FOR_NEXT_SHOT,
  READY,
  //waiting
}

class MapViewModel extends ChangeNotifier {
  Position? position;
  GoogleMapController? mapController;

  LatLng? currentPosition;
  LatLng? nextShot;
  LatLng? green;

  MapState state = MapState.WAITING_FOR_CURRENT_POSITION;

  final List<Club> clubs = [
    Club("SW", 90),
    Club("PW", 110),
    Club("9 Iron", 120),
    Club("8 Iron", 135),
    Club("7 Iron", 150),
    Club("6 Iron", 165),
    Club("5 Iron", 180),
    Club("4 Iron", 190),
    Club("Driver", 220),
  ];

  bool _weatherLoaded = false;
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
      onPositionUpdated(pos);

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
  void setCurrentPosition() {
    if (position == null) return;

    currentPosition = LatLng(position!.latitude, position!.longitude);
    state = MapState.WAITING_FOR_GREEN;
    notifyListeners();
  }

  void setNextShot() {
    if (position == null) return;

    currentPosition = LatLng(position!.latitude, position!.longitude);
    state = MapState.WAITING_FOR_GREEN;
    notifyListeners();
  }

  /// Klick på karta – används bara för green
  void onMapTap(LatLng point) {
    if (state != MapState.WAITING_FOR_GREEN || state != MapState.WAITING_FOR_NEXT_SHOT) return;

    if(state == MapState.WAITING_FOR_GREEN) {
      green = point;
    }

    if(state == MapState.WAITING_FOR_NEXT_SHOT) {
      nextShot = point;
      state = MapState.READY;
    }

    notifyListeners();
  }

  /// Flytta green igen
  void resetGreen() {
    green = null;
    state = MapState.WAITING_FOR_GREEN;
    notifyListeners();
  }

  /// Flytta green igen
  void resetNextShot() {
    nextShot = null;
    state = MapState.WAITING_FOR_NEXT_SHOT;
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

  double get distanceToNextShot {
    if (position == null || nextShot == null) return 0;
    return Geolocator.distanceBetween(
      position!.latitude,
      position!.longitude,
      nextShot!.latitude,
      nextShot!.longitude,
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

  void onPositionUpdated(Position pos) {
    position = pos;

    if (!_weatherLoaded) {
      _weatherLoaded = true;
      notifyListeners(); // triggar MapScreen första gången
    }

    notifyListeners();
  }


}
