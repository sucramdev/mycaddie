import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/map_viewmodel.dart';

class InfoCard extends StatelessWidget {
  const InfoCard({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<MapViewModel>();

    if (vm.phase != HolePhase.playing) return const SizedBox();

    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("${vm.distanceToGreen.round()} m till green",
                style: const TextStyle(fontSize: 18)),
            Text("Vind: ${vm.windSpeed} m/s"),
            const SizedBox(height: 6),
            Text("Rekommenderad klubba: ${vm.recommendedClub.name}",
                style: const TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}
