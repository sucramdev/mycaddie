import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../viewmodels/map_viewmodel.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      context.read<MapViewModel>().startTracking();
    });
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<MapViewModel>();

    return Scaffold(
      appBar: AppBar(title: const Text("Caddie Map")),
      body: Stack(
        children: [
          GoogleMap(
            mapType: MapType.satellite,
            myLocationEnabled: true,
            myLocationButtonEnabled: true,
            initialCameraPosition: const CameraPosition(
              target: LatLng(0, 0),
              zoom: 17,
            ),
            onMapCreated: vm.onMapCreated,
            onTap: vm.onMapTap,
            markers: {
              if (vm.tee != null)
                Marker(
                  markerId: const MarkerId("tee"),
                  position: vm.tee!,
                  icon: BitmapDescriptor.defaultMarkerWithHue(
                    BitmapDescriptor.hueBlue,
                  ),
                ),
              if (vm.green != null)
                Marker(
                  markerId: const MarkerId("green"),
                  position: vm.green!,
                  icon: BitmapDescriptor.defaultMarkerWithHue(
                    BitmapDescriptor.hueGreen,
                  ),
                ),
            },
          ),

          /// INFO-KORT (flyttad upp – täcker inte zoom)
          if (vm.phase == MapPhase.ready)
            Positioned(
              bottom: 120,
              left: 16,
              right: 16,
              child: Card(
                elevation: 6,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        "${vm.distanceToGreen.round()} m till green",
                        style: const TextStyle(fontSize: 18),
                      ),
                      Text("Vind: ${vm.windSpeed} m/s"),
                      const SizedBox(height: 6),
                      Text(
                        "Rekommenderad klubba: ${vm.recommendedClub.name}",
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ),
            ),

          /// ACTION-KNAPP
          Positioned(
            bottom: 20,
            right: 20,
            child: FloatingActionButton.extended(
              icon: const Icon(Icons.flag),
              label: Text(
                vm.phase == MapPhase.waitingForTee
                    ? "Sätt tee"
                    : vm.phase == MapPhase.waitingForGreen
                    ? "Sätt green"
                    : "Ändra green",
              ),
              onPressed: () {
                if (vm.phase == MapPhase.waitingForTee) {
                  vm.setTee();
                } else if (vm.phase == MapPhase.ready) {
                  vm.resetGreen();
                }
              },
            ),
          ),
          /// AVSLUTA HÅL
          if (vm.phase == MapPhase.ready)
            Positioned(
              bottom: 20,
              left: 20,
              child: FloatingActionButton.extended(
                heroTag: "finishHole",
                icon: const Icon(Icons.check),
                label: const Text("Avsluta hål"),
                onPressed: () {
                  Navigator.pushNamed(context, '/score');
                },
              ),
            ),
        ],
      ),
    );
  }
}
