import 'package:Lotie_Flutter/src/animatables.dart';
import 'package:Lotie_Flutter/src/converters.dart';
import 'package:Lotie_Flutter/src/values.dart';
import 'package:flutter/painting.dart' show Offset;

abstract class Shape {
}

class ShapeGroup extends Shape {
  final String _name;
  final List<Shape> _shapes;

  String get name => name;

  List<Shape> get shapes => _shapes;

  ShapeGroup(this._name, this._shapes);

  ShapeGroup.fromMap(dynamic map, double scale)
      : _name = map['nm'],
        _shapes = parseRawShapes(map['it'], scale);

  static List<Shape> parseRawShapes(List rawShapes, double scale) =>
      rawShapes.map((rawShape) => shapeFromMap(rawShape, scale))
          .toList();
}


class ShapeStroke extends Shape {
  ShapeStroke.fromMap(dynamic map, double scale);
}

class ShapeFill extends Shape {
  ShapeFill.fromMap(dynamic map, double scale);
}

class GradientStroke extends Shape {
  GradientStroke.fromMap(dynamic map, double scale);
}

class GradientFill extends Shape {
  GradientFill.fromMap(dynamic map, double scale);
}

class ShapePath extends Shape {
  ShapePath.fromMap(dynamic map, double scale);
}

class CircleShape extends Shape {
  CircleShape.fromMap(dynamic map, double scale);
}

class RectangleShape extends Shape {
  RectangleShape.fromMap(dynamic map, double scale);
}

class ShapeTrimPath extends Shape {
  ShapeTrimPath.fromMap(dynamic map, double scale);
}

class PolystarShape extends Shape {
  PolystarShape.fromMap(dynamic map, double scale);
}

class MergePaths extends Shape {
  MergePaths.fromMap(dynamic map, double scale);
}

class UnknownShape extends Shape {}

