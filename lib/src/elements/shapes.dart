import 'package:Lotie_Flutter/src/animatables.dart';
import 'package:Lotie_Flutter/src/drawing/animation_drawables.dart';
import 'package:Lotie_Flutter/src/drawing/drawing.dart';
import 'package:Lotie_Flutter/src/parsers/element_parsers.dart';
import 'package:Lotie_Flutter/src/values.dart';
import 'package:flutter/painting.dart';
import 'package:meta/meta.dart';

abstract class Shape {
  final String _name;

  String get name => _name;

  Shape.fromMap(dynamic map) : _name = parseName(map);

  AnimationDrawable toDrawable(Repaint repaint) => null;
}

class CircleShape extends Shape {
  final AnimatableValue<Offset> _position;
  final AnimatablePointValue _size;

  CircleShape.fromMap(dynamic map, double scale)
      : _position = parsePathOrSplitDimensionPath(map, scale),
        _size = parseSize(map, scale),
        super.fromMap(map);

  @override
  AnimationDrawable toDrawable(Repaint repaint) =>
      new EllipseDrawable(name, repaint,
          _size.createAnimation(), _position.createAnimation());
}

class RectangleShape extends Shape {
  final AnimatableValue<Offset> _position;
  final AnimatablePointValue _size;
  final AnimatableDoubleValue _cornerRadius;

  RectangleShape.fromMap(dynamic map, double scale)
      : _position = parsePathOrSplitDimensionPath(map, scale),
        _size = parseSize(map, scale),
        _cornerRadius = new AnimatableDoubleValue.fromMap(map['r'], scale),
        super.fromMap(map);

  @override
  AnimationDrawable toDrawable(Repaint repaint) =>
      new RectangleDrawable(
          name, repaint, _position.createAnimation(), _size.createAnimation(),
          _cornerRadius.createAnimation());
}

class PolystarShape extends Shape {

  final PolystarShapeType _type;
  final AnimatableDoubleValue _points;
  final AnimatableValue<Offset> _position;
  final AnimatableDoubleValue _rotation;
  final AnimatableDoubleValue _innerRadius;
  final AnimatableDoubleValue _outerRadius;
  final AnimatableDoubleValue _innerRoundness;
  final AnimatableDoubleValue _outerRoundness;

  PolystarShape.fromMap(dynamic map, double scale)
      : _type = parserPolystarShapeType(map),
        _position = parsePathOrSplitDimensionPath(map, scale),
        _points = new AnimatableDoubleValue.fromMap(map['pt'], scale),
        _rotation = new AnimatableDoubleValue.fromMap(map['r'], scale),
        _outerRadius = new AnimatableDoubleValue.fromMap(map['or'], scale),
        _outerRoundness = new AnimatableDoubleValue.fromMap(map['os'], scale),
        _innerRadius = parseinnerRadius(map, scale),
        _innerRoundness = parseInnerRoundness(map, scale),
        super.fromMap(map);
}

class UnknownShape extends Shape {
  UnknownShape() : super.fromMap({});
}

