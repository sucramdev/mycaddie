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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MapViewModel>().startTracking();
    });
  }

  @override
  void dispose() {
    context.read<MapViewModel>().stopTracking();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<MapViewModel>();

    final markers = <Marker>{
      // 🔵 DU
      if (vm.position != null)
        Marker(
          markerId: const MarkerId("me"),
          position: LatLng(
            vm.position!.latitude,
            vm.position!.longitude,
          ),
          icon: BitmapDescriptor.defaultMarkerWithHue(
            BitmapDescriptor.hueAzure,
          ),
        ),

      // 🟢 GREEN
      Marker(
        markerId: const MarkerId("green"),
        position: vm.currentHole.green,
        icon: BitmapDescriptor.defaultMarkerWithHue(
          BitmapDescriptor.hueGreen,
        ),
      ),

      // 🎯 AIM
      if (vm.aimPoint != null)
        Marker(
          markerId: const MarkerId("aim"),
          position: vm.aimPoint!,
        ),
    };

    return Scaffold(
      appBar: AppBar(title: const Text("Hole map")),
      body: Stack(
        children: [
          GoogleMap(
            mapType: MapType.satellite,
            initialCameraPosition: const CameraPosition(
              target: LatLng(59.3293, 18.0686), // fallback
              zoom: 17,
            ),
            myLocationEnabled: false, // vi hanterar själva
            onMapCreated: vm.onMapCreated,
            onTap: vm.setAim,
            markers: markers,
          ),

          Positioned(
            bottom: 20,
            left: 20,
            right: 20,
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text("${vm.distanceToGreen().round()} m till green"),
                    Text("Vind: ${vm.windSpeed} m/s"),
                    Text("Rekommenderad klubba: ${vm.recommendedClub().name}"),
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
