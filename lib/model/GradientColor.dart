import 'package:Lotie_Flutter/utils/GammaEvaluator.dart';
import 'package:Lotie_Flutter/utils/Maths.dart' as math;
import 'package:flutter/material.dart';

class GradientColor {
  final List<double> _positions;
  final List<Color> _colors;

  GradientColor(this._positions, this._colors);

  List<double> get positions => _positions;

  List<Color> get colors => _colors;

  int get length => _colors.length;

  void lerp(GradientColor gc1, GradientColor gc2, double progress) {
    if (gc1.length != gc2.length) {
      throw new ArgumentError(
          "Cannot interpolate between gradients. Lengths vary (${gc1
              .length} vs ${gc2.length})");
    }

    for (int i = 0; i < gc1.colors.length; i++) {
      positions[i] = math.lerp(gc1.positions[i], gc2.positions[i], progress);
      colors[i] = GammaEvaluator.evaluate(progress, gc1.colors[i], gc2.colors[i]);
    }
  }

}