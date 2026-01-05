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
    required Course course
  }) {
    final holes = List.generate(course.holePars.length, (i) {
      return Hole(
        number: i + 1,
        par: course.holePars[i],
        hcpIndex: course.holeHcpIndex[i],
      );
    });

    _currentSession = Session(
      course: course,
      holes: holes,
    );

    notifyListeners();
  }

  void registerScore(int strokes, double playerHcp) {
    final session = _currentSession;
    if (session == null) return;

    final hole = session.currentHole;
    final score = session.currentScore;

    final extra = session.strokesReceivedOnHole(playerHcp, hole.number);
    final netPar = hole.par + extra;

    final points = (2 + (netPar - strokes));
    score.strokes = strokes;
    score.points = points < 0 ? 0 : points;

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
