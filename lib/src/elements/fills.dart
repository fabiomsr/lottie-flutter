import 'package:Lotie_Flutter/src/animatables.dart';
import 'package:Lotie_Flutter/src/elements/shapes.dart';
import 'package:Lotie_Flutter/src/parsers/element_parsers.dart';
import 'package:Lotie_Flutter/src/values.dart';
import 'package:flutter/painting.dart' show PathFillType;

abstract class Fill extends Shape {

  final PathFillType _type;
  final AnimatableIntegerValue _opacity;

  Fill.fromMap(map)
      : _opacity = parseOpacity(map),
        _type = parseFillType(map),
        super.fromMap(map);
}

class ShapeFill extends Shape {
  final bool _fillEnabled;
  final AnimatableColorValue _color;

  ShapeFill.fromMap(dynamic map, double scale)
      : _color = parseColor(map),
        _fillEnabled = map["fillEnabled"],
        super.fromMap(map);
}


class GradientFill extends Shape {

  final GradientType _gradientType;
  final AnimatablePointValue _start;
  final AnimatablePointValue _end;
  final AnimatableGradientColorValue _gradientColor;

  GradientFill.fromMap(dynamic map, double scale)
      : _gradientColor = parseGradient(map),
        _gradientType = parseGradientType(map),
        _start = parseStartPoint(map, scale),
        _end = parseEndPoint(map, scale),
        super.fromMap(map);
}