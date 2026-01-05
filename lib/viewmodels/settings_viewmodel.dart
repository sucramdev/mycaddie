import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/club.dart';

class SettingsViewModel extends ChangeNotifier {
  static const _kShowWind = 'showWind';
  static const _kUseMeters = 'useMeters';
  static const _kClubsJson = 'clubsJson';
  static const _kClubsStats = 'clubsStats';

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

  bool _loaded = false;

  /// Ladda inställningar från telefonen (kalla en gång vid start)
  Future<void> load() async {
    if (_loaded) return;

    final prefs = await SharedPreferences.getInstance();

    showWind = prefs.getBool(_kShowWind) ?? showWind;
    useMeters = prefs.getBool(_kUseMeters) ?? useMeters;

    final clubsJson = prefs.getString(_kClubsJson);
    if (clubsJson != null) {
      final decoded = jsonDecode(clubsJson) as List<dynamic>;
      clubs = decoded.map((e) {
        final m = e as Map<String, dynamic>;
        return Club(
          m['name'] as String,
          (m['maxDistance'] as num).toDouble(),
        );
      }).toList();
    }

    _loaded = true;
    notifyListeners();
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setBool(_kShowWind, showWind);
    await prefs.setBool(_kUseMeters, useMeters);

    final encoded = jsonEncode(
      clubs
          .map((c) => {
        'name': c.name,
        'maxDistance': c.averageDistance,
      })
          .toList(),
    );
    await prefs.setString(_kClubsJson, encoded);
  }


  void saveNewDistances() async {
    await _save();
  }

  void toggleWind() {
    showWind = !showWind;
    notifyListeners();
    _save();
  }

  void toggleUnits() {
    useMeters = !useMeters;
    notifyListeners();
    _save();
  }

  void updateClubDistance(int index, double newDistance) {
    if (index < 0 || index >= clubs.length) return;
    if (newDistance.isNaN || newDistance.isInfinite) return;
    if (newDistance < 0) return;

    final club = clubs[index];
    clubs = List.of(clubs)..[index] = Club(club.name, newDistance);

    notifyListeners();
    _save();
  }

  Future<void> setClubDistances(Map<String, double> distancesByName) async {
    clubs = clubs.map((c) {
      final d = distancesByName[c.name];
      if (d == null) return c;

      // validering
      if (d.isNaN || d.isInfinite || d < 0) return c;

      return Club(c.name, d);
    }).toList();

    notifyListeners();
    await _save();
  }


  Future<void> resetToDefaults() async {
    showWind = true;
    useMeters = true;
    clubs = [
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
    notifyListeners();
    await _save();
  }
}
