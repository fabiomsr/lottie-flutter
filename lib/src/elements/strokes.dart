import 'package:Lotie_Flutter/src/animatables.dart';
import 'package:Lotie_Flutter/src/elements/shapes.dart';

import 'package:Lotie_Flutter/src/parsers/element_parsers.dart';
import 'package:Lotie_Flutter/src/values.dart';
import 'package:flutter/painting.dart' show StrokeCap;


abstract class Stroke extends Shape {
  final StrokeCap _capType;
  // TODO: issue Paint.Join https://github.com/flutter/flutter/issues/7199
  final JoinType _joinType;
  final LineDashGroup _lineDashGroup;
  final AnimatableDoubleValue _width;
  final AnimatableIntegerValue _opacity;

  AnimatableDoubleValue get offset => _lineDashGroup.offset;

  List<AnimatableDoubleValue> get lineDashPattern => _lineDashGroup.lineDashPattern;

  AnimatableIntegerValue get opacity => _opacity;

  AnimatableDoubleValue get width => _width;

  StrokeCap get capType => _capType;

  JoinType get jointType => _joinType;

  Stroke.fromMap(dynamic map, double scale)
      : _opacity = parseOpacity(map),
        _width = parseWidth(map, scale),
        _capType = parseCapType(map),
        _joinType = parseJoinType(map),
        _lineDashGroup = parseLineDash(map, scale),
        super.fromMap(map);
}

class ShapeStroke extends Stroke {
  final AnimatableColorValue _color;

  AnimatableColorValue get color => _color;

  ShapeStroke.fromMap(dynamic map, double scale)
      : _color = parseColor(map),
        super.fromMap(map, scale);
}

class GradientStroke extends Stroke {
  final AnimatableGradientColorValue _gradientColor;
  final AnimatablePointValue _start;
  final AnimatablePointValue _end;
  final GradientType _type;

  GradientType get type => _type;

  AnimatablePointValue get end => _end;

  AnimatablePointValue get start => _start;

  AnimatableGradientColorValue get gradientColor => _gradientColor;

  GradientStroke.fromMap(dynamic map, double scale)
      : _gradientColor = parseGradient(map),
        _type = parseGradientType(map),
        _start = parseStartPoint(map, scale),
        _end = parseEndPoint(map, scale),
        super.fromMap(map, scale);
}

