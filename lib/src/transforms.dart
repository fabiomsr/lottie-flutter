import 'package:Lotie_Flutter/src/animatables.dart';
import 'package:Lotie_Flutter/src/values.dart';

class AnimatableTransform {
  final AnimatablePathValue _anchorPoint;
  final AnimatableValue<PointF> _position;
  final AnimatableScaleValue _scale;
  final AnimatableDoubleValue _rotation;
  final AnimatableIntegerValue _opacity;

  AnimatablePathValue get anchorPoint => _anchorPoint;

  AnimatableValue<PointF> get position => _position;

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
    AnimatableValue<PointF> positionTransform;
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