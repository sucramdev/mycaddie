import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/settings_viewmodel.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsViewModel>();

    return Scaffold(
      appBar: AppBar(title: const Text("Inställningar")),
      body: ListView(
        children: [
          SwitchListTile(
            title: const Text("Visa vind"),
            value: settings.showWind,
            onChanged: (_) => settings.toggleWind(),
          ),
          SwitchListTile(
            title: const Text("Använd meter"),
            value: settings.useMeters,
            onChanged: (_) => settings.toggleUnits(),
          ),
        ],
      ),
    );
  }
}
