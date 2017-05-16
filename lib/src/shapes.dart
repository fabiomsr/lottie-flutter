import 'package:Lotie_Flutter/src/animatables.dart';
import 'package:Lotie_Flutter/src/converters.dart';
import 'package:Lotie_Flutter/src/values.dart';
import 'package:flutter/painting.dart' show Offset, PathFillType, StrokeCap;

abstract class Shape {
  final String _name;

  String get name => _name;

  Shape(this._name);
}

class ShapeGroup extends Shape {
  final List<Shape> _shapes;

  List<Shape> get shapes => _shapes;

  ShapeGroup(String name, this._shapes) : super(name);

  ShapeGroup.fromMap(dynamic map, double scale)
      : _shapes = parseRawShapes(map['it'], scale),
        super(map['nm']);

  static List<Shape> parseRawShapes(List rawShapes, double scale) =>
      rawShapes.map((rawShape) => shapeFromMap(rawShape, scale))
          .toList();
}

enum JoinType { Miter, Round, Bevel }

class ShapeStroke extends Shape {

  final AnimatableDoubleValue _offset;
  final List<AnimatableDoubleValue> _lineDashPattern;
  final AnimatableColorValue _color;
  final AnimatableIntegerValue _opacity;
  final AnimatableDoubleValue _width;
  final StrokeCap _capType;

  // TODO: Open issue about Paint.Join
  final JoinType joinType;

  AnimatableDoubleValue get offset => _offset;

  List<AnimatableDoubleValue> get lineDashPattern => _lineDashPattern;

  AnimatableColorValue get color => _color;

  AnimatableIntegerValue get opacity => _opacity;

  AnimatableDoubleValue get width => _width;

  StrokeCap get capType => _capType;

  ShapeStroke._(String name, this._offset, this._lineDashPattern, this._color,
      this._opacity, this._width, this._capType, this.joinType) : super(name);

  factory ShapeStroke(dynamic map, double scale){
    final String name = map["nm"];
    final color = new AnimatableColorValue.fromMap(map["c"]);
    final shapeWith = new AnimatableDoubleValue.fromMap(map["w"], scale);
    final opacity = new AnimatableIntegerValue.fromMap(map["o"]);
    final capType = StrokeCap.values[map["lc"] - 1];
    final joinType = JoinType.values[map["lj"] - 1];

    AnimatableDoubleValue offset;
    final lineDashPattern = new List<AnimatableDoubleValue>();

    if (map.contains("d")) {
      List rawDashes = map["d"];
      for (var rawDash in rawDashes) {
        final String n = rawDash["n"];
        if (n == "o") {
          offset = new AnimatableDoubleValue.fromMap(rawDash["v"], scale);
        } else if (n == "d" || n == "g") {
          lineDashPattern.add(
              new AnimatableDoubleValue.fromMap(rawDash["v"], scale));
        }
      }

      if (lineDashPattern.length == 1) {
        // If there is only 1 value then it is assumed to be equal parts on and off.
        lineDashPattern.add(lineDashPattern[0]);
      }
    }

    return new ShapeStroke._(
        name,
        offset,
        lineDashPattern,
        color,
        opacity,
        shapeWith,
        capType,
        joinType);
  }
}

class ShapeFill extends Shape {
  final bool _fillEnabled;
  final PathFillType _fillType;
  final AnimatableColorValue _color;
  final AnimatableIntegerValue _opacity;

  ShapeFill._(String name, this._fillEnabled, this._fillType, this._color,
      this._opacity) : super(name);

  factory ShapeFill (dynamic map, double scale) {
    final String name = map["nm"];
    final color = map.containsKey("c") ? new AnimatableColorValue.fromMap(
        map["c"])
        : null;
    final opacity = map.containsKey("o") ? new AnimatableIntegerValue.fromMap(
        map["c"]) : null;
    bool fillEnabled = map["fillEnabled"];

    int rawFillType = map.containsKey("r") ? map["r"] : 1;
    final fillType = rawFillType == 1 ? PathFillType.nonZero : PathFillType.evenOdd;

    return new ShapeFill._(name, fillEnabled, fillType, color, opacity);
  }
}

class GradientStroke extends Shape {
  GradientStroke.fromMap(dynamic map, double scale) : super('');
}

class GradientFill extends Shape {
  GradientFill.fromMap(dynamic map, double scale) : super('');
}

class ShapePath extends Shape {
  ShapePath.fromMap(dynamic map, double scale) : super('');
}

class CircleShape extends Shape {
  CircleShape.fromMap(dynamic map, double scale): super('');
}

class RectangleShape extends Shape {
  RectangleShape.fromMap(dynamic map, double scale): super('');
}

class ShapeTrimPath extends Shape {
  ShapeTrimPath.fromMap(dynamic map, double scale): super('');
}

class PolystarShape extends Shape {
  PolystarShape.fromMap(dynamic map, double scale): super('');
}

class MergePaths extends Shape {
  MergePaths.fromMap(dynamic map, double scale): super('');
}

class UnknownShape extends Shape {
  UnknownShape() : super('');
}

