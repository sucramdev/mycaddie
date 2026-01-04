import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/settings_viewmodel.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final Map<String, TextEditingController> _controllers = {};
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (_initialized) return;

    final s = context.read<SettingsViewModel>();
    for (final club in s.clubs) {
      _controllers[club.name] = TextEditingController(
        text: club.maxDistance.toStringAsFixed(0),
      );
    }

    _initialized = true;
  }

  @override
  void dispose() {
    for (final c in _controllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _saveClubs() async {
    final s = context.read<SettingsViewModel>();

    final Map<String, double> distances = {};
    for (final entry in _controllers.entries) {
      final raw = entry.value.text.trim().replaceAll(',', '.');
      final parsed = double.tryParse(raw);
      if (parsed != null) {
        distances[entry.key] = parsed;
      }
    }

    await s.setClubDistances(distances);

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Klubbdistanser sparade")),
    );
  }

  @override
  Widget build(BuildContext context) {
    final s = context.watch<SettingsViewModel>();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Inställningar"),
        actions: [
          IconButton(
            tooltip: "Spara",
            icon: const Icon(Icons.save),
            onPressed: _saveClubs,
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          SwitchListTile(
            title: const Text("Visa vind"),
            value: s.showWind,
            onChanged: (_) => s.toggleWind(),
          ),
          SwitchListTile(
            title: const Text("Meter"),
            value: s.useMeters,
            onChanged: (_) => s.toggleUnits(),
          ),
          const SizedBox(height: 12),
          const Text(
            "Klubbdistanser (max)",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),

          ...List.generate(s.clubs.length, (i) {
            final club = s.clubs[i];

            final controller = _controllers.putIfAbsent(
              club.name,
                  () => TextEditingController(
                text: club.maxDistance.toStringAsFixed(0),
              ),
            );

            return Card(
              child: ListTile(
                title: Text(club.name),
                subtitle: Text("${club.maxDistance.round()} m"),
                trailing: SizedBox(
                  width: 110,
                  child: TextFormField(
                    controller: controller,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: "meter",
                      isDense: true,
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}
