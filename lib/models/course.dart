class Course {
  final String name;
  final double courseRating;
  final int slopeRating;
  final List<int> holePars;
  final List<int> holeHcpIndex;

  Course({
    required this.name,
    required this.courseRating,
    required this.slopeRating,
    required this.holePars,
    required this.holeHcpIndex,
  }) : assert(holePars.length == holeHcpIndex.length);

  int get holesCount => holePars.length;

  int get coursePar {
    final par = holePars.fold(0, (sum, p) => sum + p);
    return holePars.length == 9 ? par * 2 : par;
  }

}
