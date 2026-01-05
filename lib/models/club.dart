import 'package:mycaddie/models/shot.dart';

class Club {
  final String name;
  double averageDistance;
  final List<Shot> shots = [];

  Club(this.name, this.averageDistance);

  void addShot(Shot shot){
    if(shot.distance < (averageDistance * 0.8) || shot.distance > (averageDistance * 1.2)) return;
    shots.add(shot);
  }

  void calcAverageDistance(){
    if(shots.isEmpty) return;
    double sum = 0;
    for(int i = 0; i < shots.length;i++) {
      sum+=shots[i].distance;
    }
    averageDistance = sum/shots.length;
  }

  Map<String, dynamic> toJson() => {
    'name': name,
    'averageDistance': averageDistance,
  };

  factory Club.fromJson(Map<String, dynamic> json) {
    return Club(
      json['name'] as String,
      (json['averageDistance'] as num).toDouble(),
    );
  }
}