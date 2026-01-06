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

    /// Visa info-panel automatiskt
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
              : "${session.course.name} • Hål ${session.currentHole.number}",
        ),
      ),
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

          /// ℹ️ INFO-PANEL
          if (_infoOffset != null)
            Positioned(
              left: _infoOffset!.dx,
              top: _infoOffset!.dy,
              child: GestureDetector(
                onTap: () => setState(() => _infoExpanded = !_infoExpanded),
                onPanUpdate: (d) =>
                    setState(() => _infoOffset = _infoOffset! + d.delta),
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
                            Icons.flag,
                            "${mapVm.distanceToGreen.round()} m till green",
                          ),
                        if (mapVm.nextShotState == NextShotState.READY)
                          _infoRow(
                            Icons.navigation,
                            "${mapVm.distanceToNextShot.round()} m till destination",
                          ),
                        Consumer<WeatherViewModel>(
                          builder: (_, wvm, __) {
                            final w = wvm.weather;
                            return _infoRow(
                              Icons.air,
                              w == null
                                  ? "Hämtar väder…"
                                  : "${w.temperature}°C • ${w.windSpeed} m/s",
                            );
                          },
                        ),
                        if (mapVm.lastShotDistance != null)
                          _infoRow(
                            Icons.timeline,
                            "Senaste slag: ${mapVm.lastShotDistance!.toStringAsFixed(1)} m",
                          ),
                        const SizedBox(height: 8),
                        const Text(
                          "Rekommenderad klubba",
                          style: TextStyle(color: Colors.white70, fontSize: 12),
                        ),
                        Text(
                          mapVm.recommendedClub.name,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),

          /// 🎮 KNAPPKOLUMN – LYFT UPP (täcker ej Google)
          Positioned(
            left: 12,
            bottom: 30, // 👈 VIKTIGT: lyfter bort från Google-texten
            child: Column(
              children: [
                _MapButton(
                  icon: Icons.my_location,
                  text: mapVm.currentPositionState ==
                      CurrentPositionState.WAITING_FOR_CURRENT_POSITION
                      ? "Sätt position"
                      : "Ändra position",
                  onTap: mapVm.setCurrentPosition,
                ),
                const SizedBox(height: 10),

                _MapButton(
                  icon: Icons.flag,
                  text: mapVm.nextShotState == NextShotState.BEFORE_SET
                      ? "Sätt nästa slag"
                      : "Ändra slag",
                  onTap: mapVm.resetNextShot,
                ),
                const SizedBox(height: 10),

                _MapButton(
                  icon: Icons.golf_course,
                  text: mapVm.greenState == GreenState.BEFORE_SET
                      ? "Sätt green"
                      : "Ändra green",
                  onTap: mapVm.resetGreen,
                ),
                const SizedBox(height: 10),

                _MapButton(
                  icon: Icons.check,
                  text: "Scorekort",
                  onTap: () {
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
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.white70),
          const SizedBox(width: 8),
          Expanded(
            child: Text(text, style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

/// 🔘 GEMENSAM KNAPP
class _MapButton extends StatelessWidget {
  final IconData icon;
  final String text;
  final VoidCallback onTap;

  const _MapButton({
    required this.icon,
    required this.text,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 160,
      child: ElevatedButton.icon(
        icon: Icon(icon, size: 18),
        label: Text(text, textAlign: TextAlign.center),
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white.withOpacity(0.95),
          foregroundColor: Colors.black,
          padding: const EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          elevation: 2,
        ),
      ),
    );
  }
}
