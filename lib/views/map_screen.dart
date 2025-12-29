import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import '../viewmodels/map_vm.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  @override
  void initState() {
    super.initState();
    context.read<MapViewModel>().updatePosition();
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<MapViewModel>();

    return Scaffold(
      appBar: AppBar(title: const Text("Hole map")),
      body: Stack(
        children: [
          GoogleMap(
            mapType: MapType.satellite,
            initialCameraPosition: const CameraPosition(
              target: LatLng(59.3293, 18.0686),
              zoom: 17,
            ),
            myLocationEnabled: true,
            onTap: vm.setAim,
            markers: {
              if (vm.aimPoint != null)
                Marker(
                  markerId: const MarkerId("aim"),
                  position: vm.aimPoint!,
                ),
            },
          ),
          if (vm.distanceToAim() != null)
            Positioned(
              bottom: 20,
              left: 20,
              right: 20,
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    children: [
                      Text(
                        "${vm.distanceToAim()!.round()} m till mål",
                        style: const TextStyle(fontSize: 18),
                      ),
                      if (vm.recommendedClub() != null)
                        Text(
                          "Rekommenderad klubba: ${vm.recommendedClub()!.name}",
                        ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
