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

  int courseHandicap(double playerHcp) {
    final extraStrokes = playerHcp * (course.slopeRating/113) +
        (course.courseRating - course.coursePar);

    return extraStrokes.round();
  }

  Map<int, int> strokesReceivedByHole(double playerHcp) {
    final ch = courseHandicap(playerHcp);

    final n = holes.length;
    if (n == 0) return {};

    // Skydd: negativa course handicap ska inte ge "minus-slag"
    final effective = ch < 0 ? 0 : ch;

    final base = effective ~/ n;
    final remainder = effective % n;

    // Sortera hål efter svårighetsgrad: hcpIndex 1 först
    final sorted = List.of(holes)
      ..sort((a, b) => a.hcpIndex.compareTo(b.hcpIndex));

    final Map<int, int> result = {};
    for (final h in holes) {
      result[h.number] = base;
    }

    for (var i = 0; i < remainder; i++) {
      final h = sorted[i];
      result[h.number] = (result[h.number] ?? 0) + 1;
    }

    return result;
  }

  int strokesReceivedOnHole(double playerHcp, int holeNumber) {
    final map = strokesReceivedByHole(playerHcp);
    return map[holeNumber] ?? 0;
  }

  // Statistik
  int get totalStrokes =>
      scores.fold(0, (sum, s) => sum + s.strokes);

  double get averageStrokes =>
      totalStrokes / scores.length;

  int get totalPoints =>
      scores.fold(0, (sum, s) => sum + s.points);

}


