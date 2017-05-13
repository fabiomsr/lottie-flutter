import 'package:Lotie_Flutter/src/animatables.dart';
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

  static List<Shape> parseRawShapes(List rawShapes, double scale) {
    final List<Shape> shapes = [];

    return rawShapes.map((rawShape) => shapeFromMap(rawShape, scale))
        .toList();
  }

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


class AnimatableTransform extends Shape {
  final AnimatablePathValue _anchorPoint;
  final AnimatableValue<Offset> _position;
  final AnimatableScaleValue _scale;
  final AnimatableDoubleValue _rotation;
  final AnimatableIntegerValue _opacity;

  AnimatablePathValue get anchorPoint => _anchorPoint;

  AnimatableValue<Offset> get position => _position;

  AnimatableScaleValue get scale => _scale;

  AnimatableDoubleValue get rotation => _rotation;

  AnimatableIntegerValue get opacity => _opacity;

  AnimatableTransform._(this._anchorPoint, this._position, this._scale,
      this._rotation, this._opacity);


  factory AnimatableTransform([dynamic map, double scale]) {
    if (map == null) {
      return new AnimatableTransform._(new AnimatablePathValue(),
          new AnimatablePathValue(), new AnimatableScaleValue(),
          new AnimatableDoubleValue(), new AnimatableIntegerValue());
    }

    AnimatablePathValue anchorPointTransform;
    AnimatableValue<Offset> positionTransform;
    AnimatableScaleValue scaleTransform;
    AnimatableDoubleValue rotationTransform;
    AnimatableIntegerValue opacityTransform;

    var rawAnchorPoint = map['a'];
    if (map != null) {
      anchorPointTransform =
      new AnimatablePathValue(rawAnchorPoint['k'], scale);
    } else {
      // Cameras don't have an anchor point property. Although we don't support
      // then, at least we won't crash
      print(
          "Layer has no transform property. You may be using an unsupported layer"
              "type such as a camera");
      anchorPointTransform = new AnimatablePathValue(null, scale);
    }


    var rawPosition = map['p'];
    if (rawPosition is Map) {
      positionTransform =
      rawPosition.containsKey('k') ? new AnimatablePathValue(
          rawPosition['k'], scale) :
      new AnimatableSplitDimensionValue(
          new AnimatableDoubleValue.fromMap(rawPosition['x'], scale),
          new AnimatableDoubleValue.fromMap(rawPosition['y'], scale));
    } else {
      _throwMissingTransform("position");
    }


    var rawScale = map['s'];
    scaleTransform =
    rawScale is Map ? new AnimatableScaleValue.fromMap(rawScale)
    // Somehow some community animations don't have scale in the transform
        : new AnimatableScaleValue();


    var rawRotation = map['r'] ?? map['rz'];
    if (rawRotation is Map) {
      rotationTransform = new AnimatableDoubleValue.fromMap(rawRotation, scale);
    } else {
      _throwMissingTransform("rotation");
    }

    var rawOpacity = map['o'];
    opacityTransform =
    rawOpacity is Map
        ? new AnimatableIntegerValue.fromMap(rawOpacity)
        : new AnimatableIntegerValue(100);

    return new AnimatableTransform._(
        anchorPointTransform, positionTransform, scaleTransform,
        rotationTransform, opacityTransform);
  }

  static void _throwMissingTransform(String missingProperty) {
    throw new ArgumentError("Missing trasnform $missingProperty");
  }

}

class UnknownShape extends Shape {}


Shape shapeFromMap(dynamic rawShape, double scale) {
  switch(rawShape['ty']) {
    case 'gr': return new ShapeGroup.fromMap(rawShape, scale);
    case 'st': return new ShapeStroke.fromMap(rawShape, scale);
    case 'gs': return new GradientStroke.fromMap(rawShape, scale);
    case 'fl': return new ShapeFill.fromMap(rawShape, scale);
    case 'gf': return new GradientFill.fromMap(rawShape, scale);
    case 'tr': return new AnimatableTransform(rawShape, scale);
    case 'sh': return new ShapePath.fromMap(rawShape, scale);
    case 'el': return new CircleShape.fromMap(rawShape, scale);
    case 'rc': return new RectangleShape.fromMap(rawShape, scale);
    case 'tm': return new ShapeTrimPath.fromMap(rawShape, scale);
    case 'sr': return new PolystarShape.fromMap(rawShape, scale);
    case 'mm': return new MergePaths.fromMap(rawShape, scale);
    default: return new UnknownShape();
  }
}