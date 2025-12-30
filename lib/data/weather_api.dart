import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/weather.dart';

class WeatherApi {
  static Future<Weather> fetchWeather(double lat, double lon) async {
    lat = double.parse(lat.toStringAsFixed(4));
    lon = double.parse(lon.toStringAsFixed(4));

    final url =
        'https://opendata-download-metfcst.smhi.se/api/category/pmp3g/'
        'version/2/geotype/point/lon/$lon/lat/$lat/data.json';

    final res = await http.get(
      Uri.parse(url),
      headers: {
        'User-Agent': 'mycaddie/1.0 (flutter)',
      },
    );

    print("SMHI STATUS: ${res.statusCode}");
    print("SMHI BODY (first 200 chars): ${res.body.substring(0, 200)}");



    final json = jsonDecode(res.body);

    final first = json['timeSeries'][0]['parameters'];

    double temp = 0;
    double windSpeed = 0;
    int windDir = 0;

    for (var p in first) {
      switch (p['name']) {
        case 't':
          temp = p['values'][0].toDouble();
          break;
        case 'ws':
          windSpeed = p['values'][0].toDouble();
          break;
        case 'wd':
          windDir = p['values'][0].toInt();
          break;
      }
    }

    return Weather(
      temperature: temp,
      windSpeed: windSpeed,
      windDirection: windDir,
    );
  }
}
