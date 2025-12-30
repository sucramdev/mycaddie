import 'package:flutter/material.dart';
import 'package:mycaddie/viewmodels/weather_viewmodel.dart';
import 'package:provider/provider.dart';

import 'viewmodels/session_viewmodel.dart';
import 'viewmodels/map_viewmodel.dart';
import 'viewmodels/settings_viewmodel.dart';

import 'views/home_screen.dart';
import 'views/map_screen.dart';
import 'views/score_screen.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => SessionViewModel()),
        ChangeNotifierProvider(create: (_) => MapViewModel()),
        ChangeNotifierProvider(create: (_) => WeatherViewModel()),
        ChangeNotifierProvider(create: (_) => SettingsViewModel()),
      ],
      child: const MyCaddieApp(),
    ),
  );
}

class MyCaddieApp extends StatelessWidget {
  const MyCaddieApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/': (_) => const HomeScreen(),
        '/map': (_) => const MapScreen(),
        '/score': (_) => const ScoreScreen(),
      },
    );
  }
}
