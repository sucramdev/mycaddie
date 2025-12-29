import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import '../viewmodels/hole_viewmodel.dart';
import '../widgets/info_card.dart';
import 'score_screen.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(
          () => context.read<HoleViewModel>().startTracking(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<HoleViewModel>();

    return Scaffold(
      appBar: AppBar(title: const Text("Hole map")),
      body: Stack(
        children: [
          GoogleMap(
            mapType: MapType.satellite,
            myLocationEnabled: true,
            onMapCreated: vm.onMapCreated,
            initialCameraPosition: const CameraPosition(
              target: LatLng(0, 0),
              zoom: 17,
            ),
            onTap: vm.setGreen,
            markers: {
              if (vm.hole.tee != null)
                Marker(
                  markerId: const MarkerId("tee"),
                  position: vm.hole.tee!,
                  icon: BitmapDescriptor.defaultMarkerWithHue(
                    BitmapDescriptor.hueBlue,
                  ),
                ),
              if (vm.hole.green != null)
                Marker(
                  markerId: const MarkerId("green"),
                  position: vm.hole.green!,
                  icon: BitmapDescriptor.defaultMarkerWithHue(
                    BitmapDescriptor.hueGreen,
                  ),
                ),
            },
          ),

          /// INFO
          const Positioned(
            bottom: 90,
            left: 16,
            right: 16,
            child: InfoCard(),
          ),
        ],
      ),

      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.flag),
        label: Text(vm.actionText),
        onPressed: () {
          if (vm.phase == HolePhase.waitingForTee) {
            vm.setTee();
          } else if (vm.phase == HolePhase.playing) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ScoreScreen()),
            );
          }
        },
      ),
    );
  }
}
