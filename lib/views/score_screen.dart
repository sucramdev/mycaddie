import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/round_viewmodel.dart';

class ScoreScreen extends StatefulWidget {
  const ScoreScreen({super.key});

  @override
  State<ScoreScreen> createState() => _ScoreScreenState();
}

class _ScoreScreenState extends State<ScoreScreen> {
  int strokes = 3;

  @override
  Widget build(BuildContext context) {
    final round = context.read<RoundViewModel>();

    return Scaffold(
      appBar: AppBar(title: const Text("Score")),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text("Slag: $strokes", style: const TextStyle(fontSize: 24)),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(onPressed: () => setState(() => strokes--), icon: const Icon(Icons.remove)),
              IconButton(onPressed: () => setState(() => strokes++), icon: const Icon(Icons.add)),
            ],
          ),
          ElevatedButton(
            onPressed: () {
              round.saveScore(strokes);
              Navigator.popUntil(context, ModalRoute.withName("/map"));
            },
            child: const Text("Spara hål"),
          )
        ],
      ),
    );
  }
}
