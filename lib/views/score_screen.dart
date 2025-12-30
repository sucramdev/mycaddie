import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/session_viewmodel.dart';
import '../viewmodels/map_viewmodel.dart';

class ScoreScreen extends StatefulWidget {
  const ScoreScreen({super.key});

  @override
  State<ScoreScreen> createState() => _ScoreScreenState();
}

class _ScoreScreenState extends State<ScoreScreen> {
  int strokes = 3;

  @override
  Widget build(BuildContext context) {
    final sessionVM = context.watch<SessionViewModel>();
    final mapVM = context.read<MapViewModel>();

    final holeNumber = sessionVM.currentSession!.currentHole.number;
    final par = sessionVM.currentSession!.currentHole.par;

    return Scaffold(
      appBar: AppBar(title: const Text("Registrera score")),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Hål $holeNumber (Par $par)",
              style: const TextStyle(fontSize: 22),
            ),
            const SizedBox(height: 24),
            Text(
              "$strokes slag",
              style: const TextStyle(fontSize: 36),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.remove),
                  onPressed: strokes > 1
                      ? () => setState(() => strokes--)
                      : null,
                ),
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: () => setState(() => strokes++),
                ),
              ],
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              child: const Text("Spara & nästa hål"),
              onPressed: () {
                sessionVM.registerScore(strokes);
                sessionVM.nextHole();
                mapVM.resetGreen(); // redo för nästa hål
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}
