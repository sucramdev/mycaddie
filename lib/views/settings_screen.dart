import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/settings_viewmodel.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final s = context.watch<SettingsViewModel>();

    return Scaffold(
      appBar: AppBar(title: const Text("Inställningar")),
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
            return Card(
              child: ListTile(
                title: Text(club.name),
                subtitle: Text("${club.maxDistance.round()} m"),
                trailing: SizedBox(
                  width: 110,
                  child: TextFormField(
                    initialValue: club.maxDistance.toStringAsFixed(0),
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: "meter",
                      isDense: true,
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (value) {
                      final parsed =
                      double.tryParse(value.replaceAll(',', '.'));
                      if (parsed == null) return;
                      s.updateClubDistance(i, parsed);
                    },
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
