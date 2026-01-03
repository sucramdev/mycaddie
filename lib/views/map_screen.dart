import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../viewmodels/map_viewmodel.dart';
import '../viewmodels/weather_viewmodel.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  Offset? _infoOffset; // sätts första gången panelen visas
  bool _infoExpanded = true;

  static const double _panelWidth = 280;

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

    /// Spawn info-panel längst upp första gången
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final shouldShow =
          vm.greenState == GreenState.READY ||
              vm.nextShotState == NextShotState.READY;

      if (shouldShow && _infoOffset == null) {
        final screenWidth = MediaQuery.of(context).size.width;
        setState(() {
          _infoOffset = Offset(
            (screenWidth - _panelWidth) / 2,
            20,
          );
        });
      }
    });

    return Scaffold(
      appBar: AppBar(title: const Text("Caddie Map")),
      body: Stack(
        children: [
          /// 🗺️ KARTA
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
                  markerId: const MarkerId("current"),
                  position: vm.currentPosition!,
                  icon: BitmapDescriptor.defaultMarkerWithHue(
                    BitmapDescriptor.hueBlue,
                  ),
                ),
              if (vm.nextShot != null)
                Marker(
                  markerId: const MarkerId("nextShot"),
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

          /// ℹ️ INFO-PANEL (spawn top → flyttbar → tap expand/minimize)
          if (_infoOffset != null)
            Positioned(
              left: _infoOffset!.dx,
              top: _infoOffset!.dy,
              child: GestureDetector(
                onTap: () {
                  setState(() => _infoExpanded = !_infoExpanded);
                },
                onPanUpdate: (details) {
                  setState(() {
                    _infoOffset = _infoOffset! + details.delta;
                  });
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: _panelWidth,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E3D2F).withOpacity(0.85),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.15),
                    ),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black54,
                        blurRadius: 14,
                        offset: Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      /// DRAG-HANDTAG
                      Center(
                        child: Container(
                          width: 42,
                          height: 4,
                          margin: const EdgeInsets.only(bottom: 10),
                          decoration: BoxDecoration(
                            color: Colors.white30,
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),

                      if (_infoExpanded) ...[
                        if (vm.greenState == GreenState.READY)
                          _infoRow(
                            icon: Icons.flag,
                            text:
                            "${vm.distanceToGreen.round()} m till green",
                          ),

                        if (vm.nextShotState == NextShotState.READY)
                          _infoRow(
                            icon: Icons.navigation,
                            text:
                            "${vm.distanceToNextShot.round()} m till destination",
                          ),

                        const SizedBox(height: 6),

                        Consumer<WeatherViewModel>(
                          builder: (_, weatherVm, __) {
                            final w = weatherVm.weather;
                            if (w == null) {
                              return _infoRow(
                                icon: Icons.cloud,
                                text: "Hämtar väder…",
                              );
                            }
                            return _infoRow(
                              icon: Icons.air,
                              text:
                              "${w.temperature}°C • ${w.windSpeed} m/s",
                            );
                          },
                        ),

                        const SizedBox(height: 8),

                        Text(
                          "Rekommenderad klubba",
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                          ),
                        ),
                        Text(
                          vm.recommendedClub.name,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ] else ...[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.golf_course,
                              color: Colors.white,
                              size: 18,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              vm.recommendedClub.name,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),

          /// 🎯 SÄTT POSITION
          Positioned(
            bottom: 20,
            right: 20,
            child: FloatingActionButton.extended(
              icon: const Icon(Icons.my_location),
              label: Text(
                vm.currentPositionState ==
                    CurrentPositionState.WAITING_FOR_CURRENT_POSITION
                    ? "Sätt position"
                    : "Ändra position",
              ),
              onPressed: vm.setCurrentPosition,
            ),
          ),

          /// 🎯 NÄSTA SLAG
          Positioned(
            bottom: 80,
            right: 20,
            child: FloatingActionButton.extended(
              icon: const Icon(Icons.flag),
              label: Text(
                vm.nextShotState == NextShotState.BEFORE_SET
                    ? "Sätt nästa slag"
                    : "Ändra slag",
              ),
              onPressed: vm.resetNextShot,
            ),
          ),

          /// ⛳ GREEN
          Positioned(
            bottom: 140,
            right: 20,
            child: FloatingActionButton.extended(
              icon: const Icon(Icons.golf_course),
              label: Text(
                vm.greenState == GreenState.BEFORE_SET
                    ? "Sätt green"
                    : "Ändra green",
              ),
              onPressed: vm.resetGreen,
            ),
          ),

          /// ✅ AVSLUTA HÅL
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
                vm.resetMarkers();
                setState(() {
                  _infoOffset = null; // spawnar om nästa hål
                  _infoExpanded = true;
                });
              },
            ),
          ),
        ],
      ),
    );
  }

  /// 🔹 Snygg ikon + text-rad
  Widget _infoRow({required IconData icon, required String text}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.white70),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
