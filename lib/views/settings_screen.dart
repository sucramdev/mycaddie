import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/settings_viewmodel.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final Map<String, TextEditingController> _clubControllers = {};
  late final TextEditingController _hcpController;
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (_initialized) return;

    final s = context.read<SettingsViewModel>();

    // HCP controller
    _hcpController = TextEditingController(
      text: s.handicap.toStringAsFixed(1),
    );

    // Club controllers
    for (final club in s.clubs) {
      _clubControllers[club.name] = TextEditingController(
        text: club.averageDistance.toStringAsFixed(0),
      );
    }

    _initialized = true;
  }

  @override
  void dispose() {
    _hcpController.dispose();
    for (final c in _clubControllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _saveAll() async {
    final s = context.read<SettingsViewModel>();

    // 1) Save handicap
    final rawHcp = _hcpController.text.trim().replaceAll(',', '.');
    final parsedHcp = double.tryParse(rawHcp);
    if (parsedHcp != null) {
      await s.setHandicap(parsedHcp);
    }

    // 2) Save clubs (avg/max distances depending on your Club meaning)
    final Map<String, double> distances = {};
    for (final entry in _clubControllers.entries) {
      final raw = entry.value.text.trim().replaceAll(',', '.');
      final parsed = double.tryParse(raw);
      if (parsed != null) {
        distances[entry.key] = parsed;
      }
    }

    await s.setClubDistances(distances);

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Inställningar sparade")),
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
            onPressed: _saveAll,
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
            "Handicap",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: _hcpController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(
              labelText: "HCP",
              isDense: true,
              border: OutlineInputBorder(),
            ),
          ),

          const SizedBox(height: 12),
          const Text(
            "Klubbdistanser",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),

          ...List.generate(s.clubs.length, (i) {
            final club = s.clubs[i];

            final controller = _clubControllers.putIfAbsent(
              club.name,
                  () => TextEditingController(
                text: club.averageDistance.toStringAsFixed(0),
              ),
            );

            return Card(
              child: ListTile(
                title: Text(club.name),
                subtitle: Text("${club.averageDistance.round()} m"),
                trailing: SizedBox(
                  width: 110,
                  child: TextFormField(
                    controller: controller,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                      signed: false,
                    ),
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
