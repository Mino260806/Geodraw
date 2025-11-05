import 'dart:math';
import 'package:function_tree/function_tree.dart';

extension PrecisionExt on double {
  static final RegExp displayRegex = RegExp(r'([.]*0)(?!.*\d)');
  
  double toPrecision(int n) => double.parse(toStringAsFixed(n));
  double p() => toPrecision(8);

  // TODO treat special case for large numbers
  // https://stackoverflow.com/a/55173692/10231266
  String display() => p().toString().replaceAll(displayRegex, "");

  bool eq(double other) => p() == other.p();
}

extension ScaleExt on double {
  double log10() => log(this) / log(10);

  double roundScale() {
    if (this == 0) return 0;

    // Get the order of magnitude (nearest power of 10) of the number
    int orderOfMagnitude = abs().log10().floor();
    double magnitude = pow(10, orderOfMagnitude).toDouble();

    // Calculate the quotient and remainder when divided by magnitude
    double quotient = this / magnitude;

    // Define the values to which the number should be rounded
    List<double> roundingValues = [1, 2, 5];

    // Find the closest rounding value
    double closestValue = roundingValues.reduce((a, b) =>
      (a - quotient).abs() < (b - quotient).abs() ? a : b);

    // Round the quotient to the closest value and multiply it back by the magnitude
    double roundedResult = closestValue * magnitude;

    return roundedResult;
  }
}

extension InterpretExt on String {
  double? interpretDouble() {
    try {
      return interpret().toDouble();
    } on FormatException {
      return null;
    }
  }
}
