import 'package:flutter/material.dart';

class SettingsViewModel extends ChangeNotifier {
  bool showWind = true;
  bool useMeters = true;

  void toggleWind() {
    showWind = !showWind;
    notifyListeners();
  }

  void toggleUnits() {
    useMeters = !useMeters;
    notifyListeners();
  }
}
