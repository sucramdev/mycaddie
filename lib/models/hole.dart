import 'package:google_maps_flutter/google_maps_flutter.dart';

class Hole {
  final int number;
  final LatLng tee;
  final LatLng green;

  Hole({
    required this.number,
    required this.tee,
    required this.green,
  });
}