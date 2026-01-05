import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mycaddie/models/shot.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/club.dart';
import '../viewmodels/settings_viewmodel.dart';

enum NextShotState {
  WAITING_FOR_NEXT_SHOT,
  READY,
  BEFORE_SET,
}

enum CurrentPositionState {
  WAITING_FOR_CURRENT_POSITION,
  READY,
}

enum GreenState {
  WAITING_FOR_GREEN,
  READY,
  BEFORE_SET,
}

class MapViewModel extends ChangeNotifier {
  MapViewModel(this._settings) {
    _settings.addListener(_onSettingsChanged);
  }

  SettingsViewModel _settings;

  // Om ProxyProvider skulle vilja byta settings-instans (ovanligt, men korrekt att stödja)
  void updateSettings(SettingsViewModel newSettings) {
    if (identical(_settings, newSettings)) return;
    _settings.removeListener(_onSettingsChanged);
    _settings = newSettings;
    _settings.addListener(_onSettingsChanged);
    notifyListeners();
  }

  void _onSettingsChanged() {
    // När klubblistor/distanser ändras vill vi att UI uppdateras
    notifyListeners();
  }

  // ---- GPS / karta ----
  Position? position;
  GoogleMapController? mapController;

  LatLng? currentPosition;
  LatLng? nextShot;
  LatLng? green;
  LatLng? _previousPosition;
  double? lastShotDistance;

  GreenState greenState = GreenState.BEFORE_SET;
  NextShotState nextShotState = NextShotState.BEFORE_SET;
  CurrentPositionState currentPositionState =
      CurrentPositionState.WAITING_FOR_CURRENT_POSITION;

  bool _weatherLoaded = false;
  StreamSubscription<Position>? _sub;



  /// Läs klubbor från SettingsViewModel (ingen hårdkodning här)
  List<Club> get clubs => _settings.clubs;

  /// Startar GPS + följer användaren
  Future<void> startTracking() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return;

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      return;
    }

    _sub?.cancel();
    _sub = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 3,
      ),
    ).listen((pos) {
      onPositionUpdated(pos);

      final controller = mapController;
      if (controller != null) {
        controller.animateCamera(
          CameraUpdate.newLatLng(LatLng(pos.latitude, pos.longitude)),
        );
      }
    });
  }

  void resetForNewSession() {
    resetStates();
    resetMarkers();

    lastShotDistance = null;

    notifyListeners();
  }


  void resetStates() {
    currentPositionState = CurrentPositionState.WAITING_FOR_CURRENT_POSITION;
    nextShotState = NextShotState.BEFORE_SET;
    greenState = GreenState.BEFORE_SET;
    notifyListeners();
  }

  void resetMarkers() {
    green = null;
    nextShot = null;
    currentPosition = null;
    notifyListeners();
  }

  void onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  /// Sätt tee = din nuvarande position
  void setCurrentPosition() {
    if (position == null) return;

    _previousPosition = currentPosition;
    currentPosition = LatLng(position!.latitude, position!.longitude);

    calculateShotDistance();

    String clubName = recommendedClub.name;

    if(lastShotDistance != null) {
      for(int i = 0 ; i < clubs.length;i++) {
        if(clubs[i].name == clubName) {
          clubs[i].addShot(Shot(clubName, lastShotDistance!));
        }
      }
    }


    // slaget är nu klart → kräver nytt mål nästa gång
    nextShot = null;
    nextShotState = NextShotState.BEFORE_SET;

    currentPositionState = CurrentPositionState.READY;
    notifyListeners();
  }

  void calculateShotDistance() {
    if (_previousPosition == null || currentPosition == null || nextShot == null) return;

    lastShotDistance = Geolocator.distanceBetween(
      _previousPosition!.latitude,
      _previousPosition!.longitude,
      currentPosition!.latitude,
      currentPosition!.longitude,
    );

  }

  void calcAvgAndSave() async {
    // 1. Räkna om snitt för alla klubbor
    for (int i = 0; i < clubs.length; i++) {
      clubs[i].calcAverageDistance();
    }
    _settings.notifyListeners();
    _settings.saveNewDistances();

  }


  /// Klick på karta – används för green och nästa slag
  void onMapTap(LatLng point) {
    final waitingForGreen = greenState == GreenState.WAITING_FOR_GREEN;
    final waitingForNext = nextShotState == NextShotState.WAITING_FOR_NEXT_SHOT;

    if (!waitingForGreen && !waitingForNext) return;

    if (waitingForGreen) {
      green = point;
      greenState = GreenState.READY;
    }

    if (waitingForNext) {
      nextShot = point;
      nextShotState = NextShotState.READY;
    }

    notifyListeners();
  }

  void resetGreen() {
    green = null;
    greenState = GreenState.WAITING_FOR_GREEN;
    notifyListeners();
  }

  void resetNextShot() {
    nextShot = null;
    nextShotState = NextShotState.WAITING_FOR_NEXT_SHOT;
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
    final list = clubs;
    if (list.isEmpty) {
      // Om du vill: kasta exception eller returnera en default.
      // Här väljer vi en defensiv fallback.
      return Club("N/A", 0);
    }

    return list.firstWhere(
          (c) => c.averageDistance >= distanceToNextShot,
      orElse: () => list.last,
    );
  }

  void onPositionUpdated(Position pos) {
    position = pos;

    if (!_weatherLoaded) {
      _weatherLoaded = true;
      notifyListeners(); // triggar MapScreen första gången
      return;
    }

    notifyListeners();
  }

  @override
  void dispose() {
    _settings.removeListener(_onSettingsChanged);
    _sub?.cancel();
    super.dispose();
  }
}
