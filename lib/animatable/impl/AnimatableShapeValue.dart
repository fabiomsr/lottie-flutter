import 'package:Lotie_Flutter/animatable/BaseAnimatableValue.dart';
import 'package:Lotie_Flutter/animation/BaseKeyframeAnimation.dart';
import 'package:Lotie_Flutter/animation/impl/StaticKeyframeAnimation.dart';
import 'package:Lotie_Flutter/model/AnimationValues.dart';
import 'package:Lotie_Flutter/model/Keyframe.dart';
import 'package:Lotie_Flutter/model/Scene.dart';
import 'package:Lotie_Flutter/parser/Parser.dart';

class AnimatableShapeValue extends BaseAnimatableValue<ShapeData, Path> {

  static final AnimatableValueParser _parser = new AnimatableValueParser<ShapeData>();

  AnimatableShapeValue._(ShapeData initialValue, Scene scene)
      : super(initialValue, scene: scene);


  factory AnimatableShapeValue(dynamic map, double scale) {
    KeyframeGroup<ShapeData> keyframeGroup = _parser.parse(map, Parsers.shapeDataParser, scale);
    return new AnimatableShapeValue._(keyframeGroup.initialValue, keyframeGroup.scene);
  }


  @override
  BaseKeyframeAnimation<dynamic, Path> createAnimation() {
    return hasAnimation ? new _ShapeKeyframeAnimation(scene) :
                          new StaticKeyframeAnimation(new Path.fromShape(initialValue));
  }
}


class _ShapeKeyframeAnimation extends BaseKeyframeAnimation<ShapeData, Path> {

  _ShapeKeyframeAnimation(Scene<ShapeData> scene) : super(scene);

  @override
  Path getValue(Keyframe<ShapeData> keyframe, double keyframeProgress) {
    final shape = new ShapeData.fromInterpolateBetween(
        keyframe.startValue, keyframe.endValue, keyframeProgress);
    return new Path.fromShape(shape);
  }
}