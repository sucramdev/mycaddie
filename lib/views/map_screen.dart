import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../viewmodels/map_viewmodel.dart';
import '../widgets/info_card.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  @override
  void initState() {
    super.initState();
    context.read<MapViewModel>().startTracking();
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
            myLocationEnabled: true,
            initialCameraPosition: const CameraPosition(
              target: LatLng(0, 0),
              zoom: 17,
            ),
            onMapCreated: vm.onMapCreated,
            onTap: vm.onMapTap,
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
          const Positioned(bottom: 90, left: 20, right: 20, child: InfoCard()),
          Positioned(
            bottom: 20,
            right: 20,
            child: FloatingActionButton.extended(
              label: Text(
                vm.phase == HolePhase.waitingForTee
                    ? "Sätt tee"
                    : vm.phase == HolePhase.waitingForGreen
                    ? "Sätt green"
                    : "Score",
              ),
              onPressed: () {
                if (vm.phase == HolePhase.playing) {
                  Navigator.pushNamed(context, "/score");
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
