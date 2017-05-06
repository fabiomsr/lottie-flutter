import 'package:Lotie_Flutter/animatable/BaseAnimatableValue.dart';
import 'package:Lotie_Flutter/animation/KeyframeAnimation.dart';
import 'package:Lotie_Flutter/animation/impl/StaticKeyframeAnimation.dart';
import 'package:Lotie_Flutter/model/Keyframe.dart';
import 'package:Lotie_Flutter/model/AnimationValues.dart';
import 'package:Lotie_Flutter/model/Scene.dart';
import 'package:Lotie_Flutter/parser/Parser.dart';
import 'package:Lotie_Flutter/utils/Maths.dart';

class AnimatableScaleValue extends BaseAnimatableValue<PointF, PointF> {

  static final AnimatableValueParser _parser = new AnimatableValueParser<PointF>();

  AnimatableScaleValue._(PointF initialValue, Scene scene)
      : super(initialValue, scene:scene);

  factory AnimatableScaleValue(dynamic map) {
    KeyframeGroup<PointF> keyframeGroup = _parser.parse(map, Parsers.scaleParser, 1.0);
    return new AnimatableScaleValue._(keyframeGroup.initialValue, keyframeGroup.scene);
  }

  @override
  KeyframeAnimation<PointF> createAnimation() {
    return hasAnimation ? new _ScaleKeyframeAnimation(scene) :
                          new StaticKeyframeAnimation(initialValue);
  }
}

class _ScaleKeyframeAnimation extends KeyframeAnimation<PointF> {

  _ScaleKeyframeAnimation(Scene<PointF> scene) : super(scene);

  @override
  PointF getValue(Keyframe<PointF> keyframe, double keyframeProgress) {
    if(keyframe.startValue == null || keyframe.endValue == null) {
      throw new StateError("Missing values for keyframe.");
    }

    PointF startTransform = keyframe.startValue;
    PointF endTransform = keyframe.endValue;

    return new PointF(lerp(startTransform.x, endTransform.x, keyframeProgress),
                      lerp(startTransform.y, endTransform.y, keyframeProgress));

  }
}