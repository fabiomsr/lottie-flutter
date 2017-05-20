import 'package:Lotie_Flutter/src/animatables.dart';
import 'package:Lotie_Flutter/src/animations.dart';
import 'package:Lotie_Flutter/src/elements/shapes.dart';
import 'package:Lotie_Flutter/src/mathutils.dart';

import 'package:Lotie_Flutter/src/parsers/element_parsers.dart';
import 'package:flutter/painting.dart' show Offset;
import 'package:vector_math/vector_math_64.dart';

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
      this._rotation, this._opacity): super.fromMap({});


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


    positionTransform = parsePathOrSplitDimensionPath(map, scale);
    if (positionTransform == null) {
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


class TransformKeyframeAnimation {
  final Matrix4 _matrix = new Matrix4.identity();
  
  final BaseKeyframeAnimation<dynamic, Offset> _anchorPoint;
  final BaseKeyframeAnimation<dynamic, Offset> _position;
  final BaseKeyframeAnimation<dynamic, Offset> _scale;
  final BaseKeyframeAnimation<dynamic, double> _rotation;
  final BaseKeyframeAnimation<dynamic, int> _opacity;

  BaseKeyframeAnimation<dynamic, Offset> get anchorpoint => _anchorPoint;
  BaseKeyframeAnimation<dynamic, Offset> get position => _position;
  BaseKeyframeAnimation<dynamic, Offset> get scale => _scale;
  BaseKeyframeAnimation<dynamic, double> get rotation => _rotation;
  BaseKeyframeAnimation<dynamic, int> get opacity => _opacity;
  
  Matrix4 get matrix {
    _matrix.setIdentity();
    final Offset position = _position.value;
    if(position.dx != 0 && position.dy != 0) {
      matrix.leftTranslate(position.dx, position.dy);
    }

    final double rotation = _rotation.value;
    if(rotation != 0) {
      leftRotate(matrix, rotation);
    }

    final Offset scale = _scale.value;
    if(scale.dx != 1 || scale.dy != 1) {
      leftScale(matrix, scale.dx, scale.dy);
    }

    final Offset anchorPoint = _anchorPoint.value;
    if(anchorPoint.dx != 0 || anchorPoint.dy != 0) {
      matrix.leftTranslate(anchorPoint.dx, anchorPoint.dy);
    }

    return matrix;
  }
  
  TransformKeyframeAnimation(AnimatableTransform animatableTransform) 
      : _anchorPoint = animatableTransform.anchorPoint.createAnimation(),
        _position = animatableTransform.position.createAnimation(),
        _scale = animatableTransform.scale.createAnimation(),
        _rotation = animatableTransform.rotation.createAnimation(),
        _opacity = animatableTransform.opacity.createAnimation();
  
  
  void addListener(OnValueChanged onValueChanged){
    _anchorPoint.addListener(onValueChanged);
    _position.addListener(onValueChanged);
    _scale.addListener(onValueChanged);
    _rotation.addListener(onValueChanged);
    _opacity.addListener(onValueChanged);
  }
  
}