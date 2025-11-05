import 'dart:math';

class QuadraticEquation {
  final double a;
  final double b;
  final double c;

  QuadraticEquation(this.a, this.b, this.c);

  List<double> solve() {
    List<double> solution = [];

    double delta = b * b - 4 * a * c;
    if (delta > 0) {
      solution.add((-b - sqrt(delta)) / (2 * a));
      solution.add((-b + sqrt(delta)) / (2 * a));
    }
    else if (delta == 0) {
      solution.add(-b / (2 * a));
    }

    return solution;
  }
}
