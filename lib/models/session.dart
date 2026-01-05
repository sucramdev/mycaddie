import 'hole.dart';
import 'hole_score.dart';
import 'course.dart';

class Session {
  final Course course;
  final DateTime startedAt;
  final List<Hole> holes;
  final List<HoleScore> scores;

  int currentHoleIndex = 0;

  Session({
    required this.course,
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

  // Statistik
  int get totalStrokes =>
      scores.fold(0, (sum, s) => sum + s.strokes);

  double get averageStrokes =>
      totalStrokes / scores.length;
}
