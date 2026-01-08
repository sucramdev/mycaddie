import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mycaddie/models/shot.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:math' as math;
import '../models/club.dart';
import '../viewmodels/settings_viewmodel.dart';
import '../models/weather.dart';

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

    if(lastShotDistance != null && shouldTrainShot) {
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

  bool get shouldTrainShot {
    if (weather == null) return true;
    return weather!.windSpeed < 10;
  }

  double get effectiveDistanceToShot {
    if (weather == null || nextShot == null) return distanceToNextShot;

    final double windSpeed = weather!.windSpeed;
    final double shotBearing = bearingToNextShot;
    final double windTo = windToDirection;

    double delta = windTo - shotBearing;
    delta = (delta + 540) % 360 - 180;

    // Motvind → längre
    if (delta.abs() > 160) {
      return distanceToNextShot * (1 + windSpeed * 0.03);
    }

    // Medvind → kortare
    if (delta.abs() < 20) {
      return distanceToNextShot * (1 - windSpeed * 0.02);
    }

    // Sidvind → påverkar ej längd (än)
    return distanceToNextShot;
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

  double get bearingToNextShot {
    if (position == null || nextShot == null) return 0;

    final lat1 = _degToRad(position!.latitude);
    final lon1 = _degToRad(position!.longitude);
    final lat2 = _degToRad(nextShot!.latitude);
    final lon2 = _degToRad(nextShot!.longitude);

    final dLon = lon2 - lon1;

    final y = math.sin(dLon) * math.cos(lat2);
    final x = math.cos(lat1) * math.sin(lat2) -
        math.sin(lat1) * math.cos(lat2) * math.cos(dLon);

    final bearingRad = math.atan2(y, x);
    final bearingDeg = (_radToDeg(bearingRad) + 360) % 360; // normalisera 0..360
    return bearingDeg;
  }

  double _degToRad(double deg) => deg * (math.pi / 180.0);
  double _radToDeg(double rad) => rad * (180.0 / math.pi);

  String bearingToCompass(double bearing) {
    const dirs = ['N ', 'NÖ', 'Ö', 'SÖ', 'S', 'SV', 'V', 'NV', 'N'];
    final idx = ((bearing % 360) / 45).round();
    return dirs[idx];
  }

  Weather? weather;

  void updateWeather(Weather newWeather) {
    weather = newWeather;
    notifyListeners();
  }

  String get windRecommendation {
    if (weather == null || position == null || nextShot == null) {
      return "";
    }

    final w = weather!;

    // 1. Vart du slår
    final double shotBearing = bearingToNextShot;

    // 2. Vind från SMHI (varifrån)
    final double windFrom = w.windDirection.roundToDouble();

    // 3. Gör om till vart vinden blåser
    final double windTo = (windFrom + 180) % 360;

    // 4. Skillnad mellan vind och slag
    double delta = windTo - shotBearing;
    delta = (delta + 540) % 360 - 180; // -180 .. +180

    final double absDelta = delta.abs();
    final double windSpeed = w.windSpeed;

    // 5. TOLKNING = KOMPENSATION (detta är ändringen)
    if (absDelta < 20) {
      return windSpeed > 3
          ? "Medvind – slå lite kortare"
          : "Svag medvind";
    }

    if (absDelta > 160) {
      return windSpeed > 3
          ? "Motvind – slå lite längre"
          : "Svag motvind";
    }

    if (delta < 0) {
      // Vind blåser åt vänster
      return windSpeed > 3
          ? "Sidvind – bollen drar åt vänster. Sikta mer åt höger"
          : "Svag sidvind – bollen drar lite åt vänster";
    } else {
      // Vind blåser åt höger
      return windSpeed > 3
          ? "Sidvind – bollen drar åt höger. Sikta mer åt vänster"
          : "Svag sidvind – bollen drar lite åt höger";
    }
  }

  double get windToDirection {
    if (weather == null) return 0;
    return (weather!.windDirection + 180) % 360;
  }


  double get windDirection {
    if (weather == null) return 0;
    return weather!.windDirection.roundToDouble();
  }


  String arrowShotDirection(double bearing) {
  if (bearing >= 337.5 || bearing < 22.5) return "↑";
  if (bearing < 67.5) return "↗";
  if (bearing < 112.5) return "→";
  if (bearing < 157.5) return "↘";
  if (bearing < 202.5) return "↓";
  if (bearing < 247.5) return "↙";
  if (bearing < 292.5) return "←";
  return "↖";
  }

  String arrowFromBearing(double bearing) {
    if (bearing >= 337.5 || bearing < 22.5) return "↓";
    if (bearing < 67.5) return "↙";
    if (bearing < 112.5) return "←";
    if (bearing < 157.5) return "↖";
    if (bearing < 202.5) return "↑";
    if (bearing < 247.5) return "↗";
    if (bearing < 292.5) return "→";
    return "↘";
  }

  /*String arrowFromBearing(double bearing) {
    const dirs = ['↓', '↙', '←', '↖', '↑', '↗', '→', '↘', '↓'];
    final idx = ((bearing % 360) / 45).round();
    return dirs[idx];
  }*/



  Club get recommendedClub {
    final list = clubs;
    if (list.isEmpty) {
      return Club("N/A", 0);
    }

    return list.firstWhere(
          (c) => c.averageDistance >= effectiveDistanceToShot,
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
