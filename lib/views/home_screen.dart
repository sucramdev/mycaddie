import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("myCaddie")),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ElevatedButton(
            onPressed: () => Navigator.pushNamed(context, "/map"),
            child: const Text("Start round"),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pushNamed(context, "/scorecard"),
            child: const Text("Scorecard"),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pushNamed(context, "/settings"),
            child: const Text("Settings"),
          ),
        ],
      ),
    );
  }
}
