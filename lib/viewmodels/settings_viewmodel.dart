import 'package:flutter/material.dart';
import '../models/club.dart';

class SettingsViewModel extends ChangeNotifier {
  bool showWind = true;
  bool useMeters = true;

  List<Club> clubs = [
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

  void toggleWind() {
    showWind = !showWind;
    notifyListeners();
  }

  void toggleUnits() {
    useMeters = !useMeters;
    notifyListeners();
  }

  void updateClubDistance(int index, double newDistance) {
    if (index < 0 || index >= clubs.length) return;

    final club = clubs[index];
    clubs = List.of(clubs)
      ..[index] = Club(club.name, newDistance);

    notifyListeners();
  }
}
