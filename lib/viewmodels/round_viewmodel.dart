import 'package:flutter/material.dart';
import '../models/hole_score.dart';
import '../models/round.dart';

class RoundViewModel extends ChangeNotifier {
  final Round round = Round();
  int currentHole = 1;

  void saveScore(int strokes) {
    round.addScore(
      HoleScore(holeNumber: currentHole, strokes: strokes),
    );
    currentHole++;
    notifyListeners();
  }
}
