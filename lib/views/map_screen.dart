import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../viewmodels/map_viewmodel.dart';
import 'package:provider/provider.dart';
import '../viewmodels/weather_viewmodel.dart';
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

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final mapVm = context.read<MapViewModel>();
      final weatherVm = context.read<WeatherViewModel>();

      mapVm.startTracking();

      mapVm.addListener(() {
        final pos = mapVm.position;
        if (pos != null &&
            weatherVm.weather == null &&
            !weatherVm.loading) {
          weatherVm.load(pos.latitude, pos.longitude);
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<MapViewModel>();
    Widget _weatherInfo() {
      final weatherVm = context.watch<WeatherViewModel>();

      if (weatherVm.loading) {
        return const Padding(
          padding: EdgeInsets.all(8),
          child: CircularProgressIndicator(),
        );
      }

      if (weatherVm.weather == null) {
        return const SizedBox.shrink();
      }

      final w = weatherVm.weather!;
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.6),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          "${w.temperature}°C  •  Vind ${w.windSpeed} m/s",
          style: const TextStyle(color: Colors.white),
        ),
      );
    }
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
              if (vm.currentPosition != null)
                Marker(
                  markerId: const MarkerId("Sätt position"),
                  position: vm.currentPosition!,
                  icon: BitmapDescriptor.defaultMarkerWithHue(
                    BitmapDescriptor.hueBlue,
                  ),
                ),
              if (vm.nextShot != null)
                Marker(
                  markerId: const MarkerId("Sätt ut position för nästa slag"),
                  position: vm.nextShot!,
                  icon: BitmapDescriptor.defaultMarkerWithHue(
                    BitmapDescriptor.hueRed,
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

          /// INFO-KORT
          if ((vm.currentPositionState == CurrentPositionState.READY && vm.greenState == GreenState.READY) || (vm.currentPositionState == CurrentPositionState.READY && vm.nextShotState == NextShotState.READY))
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
                      if(vm.greenState == GreenState.READY)
                          Text(
                            "${vm.distanceToGreen.round()} m till green",
                            style: const TextStyle(fontSize: 18),
                          ),
                      if(vm.nextShotState == NextShotState.READY)
                        Text(
                          "${vm.distanceToNextShot.round()} m till din destination",
                          style: const TextStyle(fontSize: 18),
                        ),
                  Text(
                        "Temp: ${context.watch<WeatherViewModel>().weather?.temperature}°C | "
                        "Vind: ${context.watch<WeatherViewModel>().weather?.windSpeed} m/s",
                  ),
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

          /// Sätt current position
          Positioned(
            bottom: 20,
            right: 20,
            child: FloatingActionButton.extended(
              icon: const Icon(Icons.flag),
              label: Text(
                vm.currentPositionState == CurrentPositionState.WAITING_FOR_CURRENT_POSITION
                    ? "Sätt position"
                    : "Ändra position",
              ),
              onPressed: () {
                  vm.setCurrentPosition();
              },
            ),
          ),

          /// SÄTT UT VART VI SKA SLÅ
          Positioned(
            bottom: 80,
            right: 20,
            child: FloatingActionButton.extended(
              icon: const Icon(Icons.flag),
              label: Text(
                  vm.nextShotState == NextShotState.BEFORE_SET ? "Sätt nästa slag" : "Ändra valt slag"
              ),
              onPressed: () {
                vm.resetNextShot();
              },
            ),
          ),

          /// SÄTT UT GREEN
          Positioned(
            bottom: 140,
            right: 20,
            child: FloatingActionButton.extended(
              icon: const Icon(Icons.flag),
              label: Text(
                  vm.greenState == GreenState.BEFORE_SET ? "Sätt green" : "Ändra green"
              ),
              onPressed: () {
                vm.resetGreen();
              },
            ),
          ),

          /// AVSLUTA HÅL
            Positioned(
              bottom: 20,
              left: 20,
              child: FloatingActionButton.extended(
                heroTag: "finishHole",
                icon: const Icon(Icons.check),
                label: const Text("Avsluta hål"),
                onPressed: () {
                  Navigator.pushNamed(context, '/score');
                  vm.resetStates();
                },
              ),
            ),
        ],
      ),
    );
  }
}
