import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/map_viewmodel.dart';
import '../viewmodels/session_viewmodel.dart';
import 'map_screen.dart';

class StartSessionScreen extends StatefulWidget {
  const StartSessionScreen({super.key});

  @override
  State<StartSessionScreen> createState() => _StartSessionScreenState();
}

class _StartSessionScreenState extends State<StartSessionScreen> {
  final _courseNameController = TextEditingController();

  // NEW: controllers for course data
  final _courseParController = TextEditingController(text: "72");
  final _courseRatingController = TextEditingController(text: "72.0");
  final _slopeRatingController = TextEditingController(text: "113");

  int holes = 18;

  @override
  void dispose() {
    _courseNameController.dispose();
    _courseParController.dispose();
    _courseRatingController.dispose();
    _slopeRatingController.dispose();
    super.dispose();
  }

  void _start() {
    final courseName = _courseNameController.text.trim();

    final coursePar = int.tryParse(_courseParController.text.trim());
    final courseRating = double.tryParse(
      _courseRatingController.text.trim().replaceAll(',', '.'),
    );
    final slopeRating = int.tryParse(_slopeRatingController.text.trim());

    // Basic validation
    if (courseName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Ange golfbana.")),
      );
      return;
    }
    if (coursePar == null || coursePar <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Ange giltigt banpar (t.ex. 72).")),
      );
      return;
    }
    if (courseRating == null || courseRating <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Ange giltig course rating (t.ex. 72.0).")),
      );
      return;
    }
    if (slopeRating == null || slopeRating <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Ange giltig slope rating (t.ex. 113).")),
      );
      return;
    }

    final mapVm = context.read<MapViewModel>();
    mapVm.resetForNewSession();

    context.read<SessionViewModel>().startSession(
      courseName: courseName,
      holesCount: holes,
      coursePar: coursePar,
      courseRating: courseRating,
      slopeRating: slopeRating,
    );

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const MapScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Ny session")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: ListView(
          children: [
            TextField(
              controller: _courseNameController,
              decoration: const InputDecoration(labelText: "Golfbana"),
            ),
            const SizedBox(height: 12),

            DropdownButtonFormField<int>(
              value: holes,
              decoration: const InputDecoration(labelText: "Antal hål"),
              items: const [
                DropdownMenuItem(value: 9, child: Text("9 hål")),
                DropdownMenuItem(value: 18, child: Text("18 hål")),
              ],
              onChanged: (v) => setState(() => holes = v ?? 18),
            ),
            const SizedBox(height: 16),

            const Text(
              "Bana",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),

            TextField(
              controller: _courseParController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: "Banans par",
                hintText: "t.ex. 72",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),

            TextField(
              controller: _courseRatingController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                labelText: "Course rating",
                hintText: "t.ex. 72.0",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),

            TextField(
              controller: _slopeRatingController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: "Slope rating",
                hintText: "t.ex. 113",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            ElevatedButton(
              onPressed: _start,
              child: const Text("Starta"),
            ),
          ],
        ),
      ),
    );
  }
}
