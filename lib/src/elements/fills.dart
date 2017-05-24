import 'package:Lotie_Flutter/src/animatables.dart';
import 'package:Lotie_Flutter/src/elements/shapes.dart';
import 'package:Lotie_Flutter/src/parsers/element_parsers.dart';
import 'package:Lotie_Flutter/src/values.dart';
import 'package:flutter/painting.dart' show PathFillType;

abstract class Fill extends Shape {

  final PathFillType _type;
  final AnimatableIntegerValue _opacity;

  Fill.fromMap(map, double durationFrames)
      : _opacity = parseOpacity(map, durationFrames),
        _type = parseFillType(map),
        super.fromMap(map);
}

class ShapeFill extends Shape {
  final bool _fillEnabled;
  final AnimatableColorValue _color;

  ShapeFill.fromMap(dynamic map, double scale, double durationFrames)
      : _color = parseColor(map, durationFrames),
        _fillEnabled = map["fillEnabled"],
        super.fromMap(map);
}


class GradientFill extends Shape {

  final GradientType _gradientType;
  final AnimatablePointValue _start;
  final AnimatablePointValue _end;
  final AnimatableGradientColorValue _gradientColor;

  GradientFill.fromMap(dynamic map, double scale, double durationFrames)
      : _gradientColor = parseGradient(map, durationFrames),
        _gradientType = parseGradientType(map),
        _start = parseStartPoint(map, scale, durationFrames),
        _end = parseEndPoint(map, scale, durationFrames),
        super.fromMap(map);
}