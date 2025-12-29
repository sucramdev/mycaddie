import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/round_viewmodel.dart';

class ScorecardScreen extends StatelessWidget {
  const ScorecardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final round = context.watch<RoundViewModel>();

    return Scaffold(
      appBar: AppBar(title: const Text("Scorecard")),
      body: ListView(
        children: round.round.scores
            .map((s) => ListTile(
          title: Text("Hål ${s.holeNumber}"),
          trailing: Text("${s.strokes} slag"),
        ))
            .toList(),
      ),
    );
  }
}
