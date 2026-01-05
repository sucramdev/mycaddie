class Hole {
  final int number;
  int par;
  int hcpIndex;

  Hole({
    required this.number,
    this.par = 0,
    this.hcpIndex = 0,
  });
}