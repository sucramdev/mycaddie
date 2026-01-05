import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/session_viewmodel.dart';

class ScorecardScreen extends StatelessWidget {
  const ScorecardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final history = context.watch<SessionViewModel>().history;

    return Scaffold(
      appBar: AppBar(title: const Text("Historik")),
      body: ListView(
        children: history.map((s) {
          return ListTile(
            title: Text(s.courseName),
            subtitle: Text(
              "Hål: ${s.holes.length} • ${s.startedAt}",
            ),
          );
        }).toList(),
      ),
    );
  }
}
