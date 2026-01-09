import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';

import 'viewmodels/session_viewmodel.dart';
import 'viewmodels/weather_viewmodel.dart';
import 'viewmodels/settings_viewmodel.dart';
import 'viewmodels/map_viewmodel.dart';

import 'views/home_screen.dart';
import 'views/map_screen.dart';
import 'views/score_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");

  final settingsVm = SettingsViewModel();
  await settingsVm.load(); // VIKTIGT: vänta in load

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => SessionViewModel()),
        ChangeNotifierProvider(create: (_) => WeatherViewModel()),
        ChangeNotifierProvider.value(value: settingsVm),

        ChangeNotifierProxyProvider<SettingsViewModel, MapViewModel>(
          create: (context) => MapViewModel(context.read<SettingsViewModel>()),
          update: (context, settings, mapVm) {
            if (mapVm == null) return MapViewModel(settings);
            mapVm.updateSettings(settings);
            return mapVm;
          },
        ),
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
