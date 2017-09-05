import 'dart:ui';
import 'package:lottie_flutter/src/animatables.dart';
import 'package:lottie_flutter/src/drawing/drawing.dart';
import 'package:lottie_flutter/src/drawing/elements/fills.dart';
import 'package:lottie_flutter/src/elements/shapes.dart';
import 'package:lottie_flutter/src/parsers/element_parsers.dart';
import 'package:lottie_flutter/src/values.dart';


abstract class Fill extends Shape {

  final PathFillType _type;
  final AnimatableIntegerValue _opacity;

  Fill.fromMap(map, double durationFrames)
      : _opacity = parseOpacity(map, durationFrames),
        _type = parseFillType(map),
        super.fromMap(map);

}

class ShapeFill extends Fill {
  final bool _fillEnabled;
  final AnimatableColorValue _color;

  ShapeFill.fromMap(dynamic map, double scale, double durationFrames)
      : _color = parseColor(map, durationFrames),
        _fillEnabled = map["fillEnabled"],
        super.fromMap(map, durationFrames);

  @override
  AnimationDrawable toDrawable(Repaint repaint) =>
      new ShapeFillDrawable(name, repaint,
          _opacity?.createAnimation(),
          _type,
          _color?.createAnimation());
}


class GradientFill extends Fill {

  final GradientType _gradientType;
  final AnimatablePointValue _start;
  final AnimatablePointValue _end;
  final AnimatableGradientColorValue _gradientColor;

  GradientFill.fromMap(dynamic map, double scale, double durationFrames)
      : _gradientColor = parseGradient(map, durationFrames),
        _gradientType = parseGradientType(map),
        _start = parseStartPoint(map, scale, durationFrames),
        _end = parseEndPoint(map, scale, durationFrames),
        super.fromMap(map, durationFrames);

  @override
  AnimationDrawable toDrawable(Repaint repaint) =>
      new GradientFillDrawable(name, repaint,
          _opacity.createAnimation(),
          _type,
          _gradientType,
          _gradientColor.createAnimation(),
          _start.createAnimation(),
          _end.createAnimation());
}