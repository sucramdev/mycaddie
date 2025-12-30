import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/session_viewmodel.dart';
import 'start_session_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final sessionVM = context.watch<SessionViewModel>();

    return Scaffold(
      appBar: AppBar(title: const Text("myCaddie")),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ElevatedButton(
            child: const Text("Starta ny session"),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const StartSessionScreen(),
                ),
              );
            },
          ),
          const SizedBox(height: 24),

          const Text(
            "Tidigare sessioner",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),

          if (sessionVM.history.isEmpty)
            const Padding(
              padding: EdgeInsets.all(12),
              child: Text("Inga sessioner ännu."),
            )
          else
            ...sessionVM.history.map((s) {
              return Card(
                child: ListTile(
                  title: Text(s.courseName),
                  subtitle: Text(
                    "${s.holes.length} hål • ${s.startedAt.toLocal()}",
                  ),
                ),
              );
            }),

          const SizedBox(height: 24),
          ElevatedButton(
            child: const Text("Inställningar"),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const SettingsScreen(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
