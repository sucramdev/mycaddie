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
      body: Stack(
        children: [
          /// 🌄 BAKGRUNDSBILD
          Positioned.fill(
            child: Image.asset(
              'assets/images/golfbild3.jpg',
              fit: BoxFit.cover,
            ),
          ),

          /// 🌑 MÖRK OVERLAY (lätt, inte grumlig)
          Positioned.fill(
            child: Container(
              color: Colors.black.withOpacity(0.35),
            ),
          ),

          /// 📄 INNEHÅLL
          SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 40),

                /// 🏌️ APP-TITEL
                Column(
                  children: const [
                    Text(
                      "myCaddie",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 36,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
                      ),
                    ),
                    SizedBox(height: 6),
                    Text(
                      "Din personliga golfcaddie",
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),

                const Spacer(),

                /// 🎯 KNAPPAR (MITTEN)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    children: [
                      if (currentSession != null) ...[
                        _PrimaryButton(
                          text: "Fortsätt session",
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const MapScreen(),
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 12),
                      ],

                      _PrimaryButton(
                        text: "Starta ny session",
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const StartSessionScreen(),
                            ),
                          );
                        },
                      ),

                      const SizedBox(height: 12),

                      _PrimaryButton(
                        text: "Inställningar",
                        onTap: () {
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
                ),

                const Spacer(),

                /// 📊 TIDIGARE RUNDOR (NEDERDEL)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.35),
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(24),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Tidigare rundor",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),

                      if (sessionVM.history.isEmpty)
                        const Text(
                          "Inga rundor ännu.",
                          style: TextStyle(color: Colors.white70),
                        )
                      else
                        ...sessionVM.history.take(3).map((s) {
                          return Card(
                            color: Colors.white.withOpacity(0.9),
                            child: ListTile(
                              title: Text(s.course.name),
                              subtitle: Text(
                                "${s.holes.length} hål • "
                                    "${s.startedAt.toLocal().toString().substring(0, 16)}",
                              ),
                              trailing: Text(
                                "${s.totalStrokes}",
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          );
                        }),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// 🔘 GEMENSAM SNYGG KNAPP (centrerad text)
class _PrimaryButton extends StatelessWidget {
  final String text;
  final VoidCallback onTap;

  const _PrimaryButton({
    required this.text,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white.withOpacity(0.9),
          foregroundColor: Colors.black,
          padding: const EdgeInsets.symmetric(vertical: 18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
          ),
          elevation: 2,
        ),
        child: Center(
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.2,
            ),
          ),
        ),
      ),
    );
  }
}
