import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/session_viewmodel.dart';
import '../viewmodels/map_viewmodel.dart';
import '../viewmodels/settings_viewmodel.dart';

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
    final settings = context.read<SettingsViewModel>();
    final handicap = settings.handicap;

    final session = sessionVM.currentSession!;
    final currentHole = session.currentHole;
    final isLastHole = session.isFinished;



    return Scaffold(
      appBar: AppBar(title: const Text("Scorekort")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            /// TIDIGARE HÅL
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: SingleChildScrollView(
                  child: Table(
                    defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                    border: TableBorder.all(color: Colors.grey.shade300),
                    columnWidths: const {
                      0: FixedColumnWidth(48), // Hål
                      1: FixedColumnWidth(48), // Par
                      2: FixedColumnWidth(48), // HCP
                      3: FixedColumnWidth(64), // Erh slag
                      4: FixedColumnWidth(64), // Slag
                      5: FixedColumnWidth(64), // Poäng
                    },
                    children: [
                      _scoreHeaderRow(),

                      ...session.holes.map((h) {
                        final score = session.scores
                            .firstWhere((s) => s.holeNumber == h.number);

                        return _scoreDataRow(
                          hole: h.number,
                          par: h.par,
                          hcp: h.hcpIndex,
                          extraStrokes: session.strokesReceivedOnHole(
                            handicap,
                            h.number,
                          ),
                          strokes: score.strokes,
                          points: score.points,
                        );
                      }),
                    ],
                  ),
                ),
              ),
            ),

            const Divider(),

            /// AKTUELLT HÅL
            Text(
              "Hål ${currentHole.number} (Par ${currentHole.par})",
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
                  onPressed: strokes > 1 ? () => setState(() => strokes--) : null,
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
                isLastHole ? "Spara & avsluta rundan" : "Spara & nästa hål",
              ),
              onPressed: () {
                sessionVM.registerScore(strokes, handicap);

                if (isLastHole) {
                  Navigator.popUntil(context, (route) => route.isFirst);

                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    sessionVM.finishSession();
                    mapVM.calcAvgAndSave();
                  });
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

  TableRow _scoreHeaderRow() {
    return TableRow(
      decoration: BoxDecoration(color: Color(0xFFEFEFEF)),
      children: [
        _headerCell("Hål"),
        _headerCell("Par"),
        _headerCell("HCP"),
        _headerCell("Erh."),
        _headerCell("Slag"),
        _headerCell("P"),
      ],
    );
  }

  TableRow _scoreDataRow({
    required int hole,
    required int par,
    required int hcp,
    required int extraStrokes,
    required int strokes,
    required int points,
  }) {
    return TableRow(
      children: [
        _cell(hole.toString()),
        _cell(par.toString()),
        _cell(hcp.toString()),
        _cell(extraStrokes > 0 ? extraStrokes.toString() : ""),
        _cell(strokes > 0 ? strokes.toString() : ""),
        _cell(strokes > 0 ? points.toString() : ""),
      ],
    );
  }

  static Widget _headerCell(String text) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
    );
  }

  static Widget _cell(String text) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Text(
        text,
        textAlign: TextAlign.center,
      ),
    );
  }
}
