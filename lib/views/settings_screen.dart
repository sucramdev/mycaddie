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
      body: Column(
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
        ],
      ),
    );
  }
}
