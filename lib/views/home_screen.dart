import 'package:flutter/material.dart';
import 'start_session_screen.dart';
import 'settings_screen.dart';
import 'scorecard_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("myCaddie")),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          ElevatedButton(
            child: const Text("Starta ny session"),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const StartSessionScreen()),
              );
            },
          ),
          ElevatedButton(
            child: const Text("Historik"),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ScorecardScreen()),
              );
            },
          ),
          ElevatedButton(
            child: const Text("Inställningar"),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SettingsScreen()),
              );
            },
          ),
        ],
      ),
    );
  }
}
