import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../viewmodels/map_viewmodel.dart';
import '../viewmodels/session_viewmodel.dart';
import '../viewmodels/weather_viewmodel.dart';
import 'score_screen.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  Offset? _infoOffset;
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
    final mapVm = context.watch<MapViewModel>();
    final sessionVm = context.watch<SessionViewModel>();
    final session = sessionVm.currentSession;

    /// Spawn info-panel automatiskt när något är satt
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final shouldShow =
          mapVm.greenState == GreenState.READY ||
              mapVm.nextShotState == NextShotState.READY;

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
      appBar: AppBar(
        title: Text(
          session == null
              ? "Caddie Map"
              : "${session.courseName} • Hål ${session.currentHole.number}",
        ),
      ),
      body: Stack(
        children: [
          /// KARTA
          GoogleMap(
            mapType: MapType.satellite,
            myLocationEnabled: true,
            myLocationButtonEnabled: true,
            initialCameraPosition: const CameraPosition(
              target: LatLng(0, 0),
              zoom: 17,
            ),
            onMapCreated: mapVm.onMapCreated,
            onTap: mapVm.onMapTap,
            markers: {
              if (mapVm.currentPosition != null)
                Marker(
                  markerId: const MarkerId("current"),
                  position: mapVm.currentPosition!,
                  icon: BitmapDescriptor.defaultMarkerWithHue(
                    BitmapDescriptor.hueBlue,
                  ),
                ),
              if (mapVm.nextShot != null)
                Marker(
                  markerId: const MarkerId("nextShot"),
                  position: mapVm.nextShot!,
                  icon: BitmapDescriptor.defaultMarkerWithHue(
                    BitmapDescriptor.hueRed,
                  ),
                ),
              if (mapVm.green != null)
                Marker(
                  markerId: const MarkerId("green"),
                  position: mapVm.green!,
                  icon: BitmapDescriptor.defaultMarkerWithHue(
                    BitmapDescriptor.hueGreen,
                  ),
                ),
            },
          ),

          /// INFO-PANEL (flyttbar + tap expand/minimize)
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
                        if (mapVm.greenState == GreenState.READY)
                          _infoRow(
                            icon: Icons.flag,
                            text:
                            "${mapVm.distanceToGreen.round()} m till green",
                          ),

                        if (mapVm.nextShotState == NextShotState.READY)
                          _infoRow(
                            icon: Icons.navigation,
                            text:
                            "${mapVm.distanceToNextShot.round()} m till destination",
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

                        const Text(
                          "Rekommenderad klubba",
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                          ),
                        ),
                        Text(
                          mapVm.recommendedClub.name,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (mapVm.lastShotDistance != null)
                          _infoRow(
                            icon: Icons.navigation,
                            text:
                            "Du slog ${mapVm.lastShotDistance} m",
                          )

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
                              mapVm.recommendedClub.name,
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

          /// SÄTT POSITION
          Positioned(
            bottom: 20,
            right: 20,
            child: FloatingActionButton.extended(
              icon: const Icon(Icons.my_location),
              label: Text(
                mapVm.currentPositionState ==
                    CurrentPositionState.WAITING_FOR_CURRENT_POSITION
                    ? "Sätt position"
                    : "Ändra position",
              ),
              onPressed: mapVm.setCurrentPosition,
            ),
          ),

          /// NÄSTA SLAG
          Positioned(
            bottom: 80,
            right: 20,
            child: FloatingActionButton.extended(
              icon: const Icon(Icons.flag),
              label: Text(
                mapVm.nextShotState == NextShotState.BEFORE_SET
                    ? "Sätt nästa slag"
                    : "Ändra slag",
              ),
              onPressed: mapVm.resetNextShot,
            ),
          ),

          ///GREEN
          Positioned(
            bottom: 140,
            right: 20,
            child: FloatingActionButton.extended(
              icon: const Icon(Icons.golf_course),
              label: Text(
                mapVm.greenState == GreenState.BEFORE_SET
                    ? "Sätt green"
                    : "Ändra green",
              ),
              onPressed: mapVm.resetGreen,
            ),
          ),

          /// AVSLUTA HÅL → SCORE
          Positioned(
            bottom: 20,
            left: 20,
            child: FloatingActionButton.extended(
              heroTag: "finishHole",
              icon: const Icon(Icons.check),
              label: const Text("Avsluta hål"),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const ScoreScreen(),
                  ),
                );

                mapVm.resetStates();
                mapVm.resetMarkers();

                setState(() {
                  _infoOffset = null;
                  _infoExpanded = true;
                });
              },
            ),
          ),
        ],
      ),
    );
  }

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
