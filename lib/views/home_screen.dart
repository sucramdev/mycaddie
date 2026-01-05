import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/session_viewmodel.dart';
import 'start_session_screen.dart';
import 'settings_screen.dart';
import 'map_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final sessionVM = context.watch<SessionViewModel>();
    final currentSession = sessionVM.currentSession;

    return Scaffold(
      appBar: AppBar(title: const Text("myCaddie")),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (currentSession != null) ...[
            Card(
              child: ListTile(
                leading: const Icon(Icons.play_arrow),
                title: Text("Fortsätt session"),
                subtitle: Text("${currentSession.courseName} • Hål ${currentSession.currentHole.number}"),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const MapScreen()),
                  );
                },
              ),
            ),
            const SizedBox(height: 12),
          ],

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
            "Tidigare rundor",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),

          if (sessionVM.history.isEmpty)
            const Padding(
              padding: EdgeInsets.all(12),
              child: Text("Inga rundor ännu."),
            )
          else
            ...sessionVM.history.map((s) {
              return Card(
                child: ListTile(
                  leading: const Icon(Icons.golf_course),
                  title: Text(s.courseName),
                  subtitle: Text(
                    "${s.holes.length} hål • "
                        "${s.startedAt.toLocal().toString().substring(0, 16)}",
                  ),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "${s.totalStrokes}",
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Text(
                        "slag",
                        style: TextStyle(fontSize: 12),
                      ),
                    ],
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
