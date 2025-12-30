import 'hole.dart';
import 'hole_score.dart';

class Session {
  final String courseName;
  final DateTime startedAt;
  final List<Hole> holes;
  final List<HoleScore> scores;

  int currentHoleIndex = 0;

  Session({
    required this.courseName,
    required this.holes,
  })  : startedAt = DateTime.now(),
        scores = holes
            .map((h) => HoleScore(holeNumber: h.number))
            .toList();

  Hole get currentHole => holes[currentHoleIndex];
  HoleScore get currentScore => scores[currentHoleIndex];

  bool get isFinished => currentHoleIndex >= holes.length - 1;

  void nextHole() {
    if (!isFinished) currentHoleIndex++;
  }
}
