import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/course.dart';
import '../models/hole.dart';
import '../models/session.dart';
import '../models/session_summary.dart';

class SessionViewModel extends ChangeNotifier {
  Session? _currentSession;
  //final List<Session> _history = [];
  final List<SessionSummary> _history = [];


  Session? get currentSession => _currentSession;
  //List<Session> get history => _history;
  List<SessionSummary> get history => _history;

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
    final session = _currentSession;
    if (session == null) return;

    _history.add(
      SessionSummary(
        courseName: session.course.name,
        startedAt: session.startedAt,
        totalStrokes: session.totalStrokes,
        holesCount: session.holes.length,
        totalPoints: session.totalPoints
      ),
    );

    _currentSession = null;
    _saveHistory();
    notifyListeners();
  }

  SessionViewModel() {
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('session_history');
    if (raw == null) return;

    final List decoded = jsonDecode(raw);
    _history
      ..clear()
      ..addAll(decoded.map((e) => SessionSummary.fromJson(e)));

    notifyListeners();
  }

  Future<void> _saveHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final encoded =
    jsonEncode(_history.map((s) => s.toJson()).toList());
    await prefs.setString('session_history', encoded);
  }
}
