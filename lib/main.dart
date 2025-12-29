import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'viewmodels/map_vm.dart';
import 'views/home_screen.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => MapViewModel()),
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
      title: 'myCaddie',
      theme: ThemeData.dark(),
      home: const HomeScreen(),
    );
  }
}
