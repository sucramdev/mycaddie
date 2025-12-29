import 'package:flutter/material.dart';

class ScoreScreen extends StatefulWidget {
  const ScoreScreen({super.key});

  @override
  State<ScoreScreen> createState() => _ScoreScreenState();
}

class _ScoreScreenState extends State<ScoreScreen> {
  int strokes = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Score")),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text("Strokes: $strokes", style: const TextStyle(fontSize: 26)),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.remove),
                onPressed: () => setState(() => strokes--),
              ),
              IconButton(
                icon: const Icon(Icons.add),
                onPressed: () => setState(() => strokes++),
              ),
            ],
          )
        ],
      ),
    );
  }
}
