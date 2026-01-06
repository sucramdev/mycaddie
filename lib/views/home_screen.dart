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
      appBar: AppBar(
        title: const Text("myCaddie"),
        backgroundColor: Colors.black.withOpacity(0.6),
      ),
      body: Stack(
        children: [
          /// BAKGRUNDSBILD
          Positioned.fill(
            child: Image.asset(
              'assets/images/golfbild2.png',
              fit: BoxFit.cover,
            ),
          ),

          /// MÖRK OVERLAY FÖR LÄSBARHET
          Positioned.fill(
            child: Container(
              color: Colors.black.withOpacity(0.45),
            ),
          ),

          /// INNEHÅLL
          ListView(
            padding: const EdgeInsets.all(16),
            children: [
              if (currentSession != null) ...[
                Card(
                  color: Colors.white.withOpacity(0.9),
                  child: ListTile(
                    leading: const Icon(Icons.play_arrow),
                    title: const Text("Fortsätt session"),
                    subtitle: Text(
                      "${currentSession.course.name} • "
                          "Hål ${currentSession.currentHole.number}",
                    ),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const MapScreen(),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 12),
              ],

              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const StartSessionScreen(),
                    ),
                  );
                },
                child: const Text("Starta ny session"),
              ),

              const SizedBox(height: 24),

              const Text(
                "Tidigare rundor",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),

              const SizedBox(height: 8),

              if (sessionVM.history.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(12),
                  child: Text(
                    "Inga rundor ännu.",
                    style: TextStyle(color: Colors.white70),
                  ),
                )
              else
                ...sessionVM.history.map((s) {
                  return Card(
                    color: Colors.white.withOpacity(0.9),
                    child: ListTile(
                      leading: const Icon(Icons.golf_course),
                      title: Text(s.course.name),
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
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const SettingsScreen(),
                    ),
                  );
                },
                child: const Text("Inställningar"),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
