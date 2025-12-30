import 'package:flutter/material.dart';
import '../data/weather_api.dart';
import '../models/weather.dart';

class WeatherViewModel extends ChangeNotifier {
  Weather? weather;
  bool loading = false;

  Future<void> load(double lat, double lon) async {
    print("WEATHER REQUEST lat=$lat lon=$lon");
    if (loading) return;

    loading = true;
    notifyListeners();

    try {
      weather = await WeatherApi.fetchWeather(lat, lon);
      print("WEATHER OK: temp=${weather!.temperature}, wind=${weather!.windSpeed}");
    } catch (e, stack) {
      print("WEATHER ERROR: $e");
      print(stack);
    }

    loading = false;
    notifyListeners();
  }
}
