import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'viewmodels/hole_viewmodel.dart';
import 'views/home_screen.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => HoleViewModel(),
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
      theme: ThemeData.dark(),
      home: const HomeScreen(),
    );
  }
}
