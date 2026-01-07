class SessionSummary {
  final String courseName;
  final DateTime startedAt;
  final int totalStrokes;
  final int holesCount;
  final int totalPoints;

  SessionSummary({
    required this.courseName,
    required this.startedAt,
    required this.totalStrokes,
    required this.holesCount,
    required this.totalPoints,
  });

  Map<String, dynamic> toJson() => {
    'courseName': courseName,
    'startedAt': startedAt.toIso8601String(),
    'totalStrokes': totalStrokes,
    'holesCount': holesCount,
  };

  factory SessionSummary.fromJson(Map<String, dynamic> json) {
    return SessionSummary(
      courseName: json['courseName'],
      startedAt: DateTime.parse(json['startedAt']),
      totalStrokes: json['totalStrokes'],
      holesCount: json['holesCount'],
      totalPoints: json['totalPoints']
    );
  }
}