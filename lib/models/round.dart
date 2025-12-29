import 'hole_score.dart';

class Round {
  final List<HoleScore> scores = [];

  void addScore(HoleScore score) {
    scores.add(score);
  }
}