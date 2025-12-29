import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'viewmodels/map_viewmodel.dart';
import 'viewmodels/round_viewmodel.dart';
import 'viewmodels/settings_viewmodel.dart';
import 'views/home_screen.dart';
import 'views/map_screen.dart';
import 'views/score_screen.dart';
import 'views/scorecard_screen.dart';
import 'views/settings_screen.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => MapViewModel()),
        ChangeNotifierProvider(create: (_) => RoundViewModel()),
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
      routes: {
        "/": (_) => const HomeScreen(),
        "/map": (_) => const MapScreen(),
        "/score": (_) => const ScoreScreen(),
        "/scorecard": (_) => const ScorecardScreen(),
        "/settings": (_) => const SettingsScreen(),
      },
    );
  }
}
