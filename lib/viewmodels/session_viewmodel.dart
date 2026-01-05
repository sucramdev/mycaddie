import 'package:flutter/material.dart';
import '../models/course.dart';
import '../models/hole.dart';
import '../models/session.dart';

class SessionViewModel extends ChangeNotifier {
  Session? _currentSession;
  final List<Session> _history = [];

  Session? get currentSession => _currentSession;
  List<Session> get history => _history;

  void startSession({
    required String courseName,
    required int holesCount,
    required int coursePar,
    required double courseRating,
    required int slopeRating,
  }) {
    final holes = List.generate(
      holesCount,
          (i) => Hole(number: i + 1, par: [3, 4, 5][i % 3]),
    );

    _currentSession = Session(
      course: Course(
        name: courseName,
        coursePar: coursePar,
        courseRating: courseRating,
        slopeRating: slopeRating,
      ),
      holes: holes,
    );

    notifyListeners();
  }

  void registerScore(int strokes) {
    _currentSession!.currentScore.strokes = strokes;
    notifyListeners();
  }

  void nextHole() {
    if (_currentSession == null) return;

    if (_currentSession!.isFinished) {
      finishSession();
    } else {
      _currentSession!.nextHole();
    }

    notifyListeners();
  }

  void finishSession() {
    _history.add(_currentSession!);
    _currentSession = null;
    notifyListeners();
  }
}
