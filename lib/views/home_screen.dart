import 'package:flutter/material.dart';
import 'map_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("myCaddie")),
      body: Center(
        child: ElevatedButton(
          child: const Text("Start round"),
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => const MapScreen(),
              ),
            );
          },
        ),
      ),
    );
  }
}
