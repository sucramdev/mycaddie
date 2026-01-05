import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/session_viewmodel.dart';
import 'map_screen.dart';

class StartSessionScreen extends StatefulWidget {
  const StartSessionScreen({super.key});

  @override
  State<StartSessionScreen> createState() => _StartSessionScreenState();
}

class _StartSessionScreenState extends State<StartSessionScreen> {
  final _controller = TextEditingController();
  int holes = 18;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Ny session")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              decoration: const InputDecoration(labelText: "Golfbana"),
            ),
            DropdownButton<int>(
              value: holes,
              items: const [
                DropdownMenuItem(value: 9, child: Text("9 hål")),
                DropdownMenuItem(value: 18, child: Text("18 hål")),
              ],
              onChanged: (v) => setState(() => holes = v!),
            ),
            ElevatedButton(
              child: const Text("Starta"),
              onPressed: () {
                context.read<SessionViewModel>().startSession(
                  courseName: _controller.text,
                  holesCount: holes,
                );
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const MapScreen()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
