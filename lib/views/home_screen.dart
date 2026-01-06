import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/session_viewmodel.dart';
import 'start_session_screen.dart';
import 'settings_screen.dart';
import 'map_screen.dart';
import 'history_screen.dart'; // 👈 se till att denna finns

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final sessionVM = context.watch<SessionViewModel>();
    final currentSession = sessionVM.currentSession;

    return Scaffold(
      body: Stack(
        children: [
          /// bakgrundsbild
          Positioned.fill(
            child: Image.asset(
              'assets/images/golfbild3.jpg',
              fit: BoxFit.cover,
            ),
          ),

          /// mörkare overlay
          Positioned.fill(
            child: Container(
              color: Colors.black.withOpacity(0.35),
            ),
          ),

          /// innehåll
          SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 40),

                /// Appens titel
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

                /// Knappar
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
                        text: "Tidigare rundor",
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const HistoryScreen(),
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
                const SizedBox(height: 40),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// GEMENSAM KNAPP
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
    );
  }
}
