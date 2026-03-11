import 'dart:math' as math;

class Formatters {
  static String bytes(int value) {
    if (value <= 0) {
      return '0 B';
    }

    const units = ['B', 'KB', 'MB', 'GB', 'TB'];
    final exponent = math.min((math.log(value) / math.log(1024)).floor(), units.length - 1);
    final size = value / math.pow(1024, exponent);
    return '${size.toStringAsFixed(size >= 10 ? 0 : 1)} ${units[exponent]}';
  }

  static String percent(double value) {
    return '${(value * 100).toStringAsFixed(0)}%';
  }
}
