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
    final session = sessionVM.currentSession!;

    final hole = session.currentHole;
    final isLastHole = session.isFinished;

    return Scaffold(
      appBar: AppBar(title: const Text("Scorekort")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            /// TIDIGARE HÅL
            Expanded(
              child: ListView(
                children: session.scores
                    .where((s) => s.strokes > 0)
                    .map(
                      (s) => ListTile(
                    leading: const Icon(Icons.golf_course),
                    title: Text("Hål ${s.holeNumber}"),
                    trailing: Text(
                      "${s.strokes} slag",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                )
                    .toList(),
              ),
            ),

            const Divider(),

            /// AKTUELLT HÅL
            Text(
              "Hål ${hole.number} (Par ${hole.par})",
              style: const TextStyle(fontSize: 20),
            ),
            const SizedBox(height: 12),

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

            const SizedBox(height: 16),

            ElevatedButton(
              child: Text(
                isLastHole
                    ? "Spara & avsluta rundan"
                    : "Spara & nästa hål",
              ),
              onPressed: () {
                sessionVM.registerScore(strokes);

                if (isLastHole) {
                  sessionVM.finishSession();
                  mapVM.calcAvgAndSave();
                  Navigator.popUntil(
                    context,
                        (route) => route.isFirst,
                  );
                } else {
                  sessionVM.nextHole();
                  mapVM.resetStates();
                  mapVM.resetMarkers();
                  Navigator.pop(context);
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
