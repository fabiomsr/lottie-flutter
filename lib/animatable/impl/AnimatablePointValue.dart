
import 'package:Lotie_Flutter/animatable/BaseAnimatableValue.dart';
import 'package:Lotie_Flutter/animation/BaseKeyframeAnimation.dart';
import 'package:Lotie_Flutter/animation/KeyframeAnimation.dart';
import 'package:Lotie_Flutter/animation/impl/StaticKeyframeAnimation.dart';
import 'package:Lotie_Flutter/model/Keyframe.dart';
import 'package:Lotie_Flutter/model/AnimationValues.dart';
import 'package:Lotie_Flutter/model/Scene.dart';
import 'package:Lotie_Flutter/parser/Parser.dart';


class AnimatablePointValue extends BaseAnimatableValue<PointF, PointF> {

  static final AnimatableValueParser _parser = new AnimatableValueParser<PointF>();

  AnimatablePointValue._(PointF initialValue, Scene scene)
      : super(initialValue, scene:scene);

  factory AnimatablePointValue(dynamic map, double scale) {
    KeyframeGroup<PointF> keyframeGroup = _parser.parse(map, Parsers.pointFParser, scale);
    return new AnimatablePointValue._(keyframeGroup.initialValue, keyframeGroup.scene);
  }

  @override
  KeyframeAnimation<PointF> createAnimation() {
    return hasAnimation ? new _PointKeyframeAnimation(scene) :
                          new StaticKeyframeAnimation(initialValue);
  }

}

class _PointKeyframeAnimation extends KeyframeAnimation<PointF>{

  _PointKeyframeAnimation(Scene<PointF> scene) : super(scene);

  @override
  PointF getValue(Keyframe<PointF> keyframe, double keyframeProgress) {
    if(keyframe.startValue == null || keyframe.endValue == null) {
      throw new StateError("Missing values for keyframe.");
    }

    PointF startPoint = keyframe.startValue;
    PointF endPoint = keyframe.endValue;

    return new PointF(startPoint.x + keyframeProgress * (endPoint.x - startPoint.x),
                  startPoint.y + keyframeProgress * (endPoint.y - startPoint.y));
  }
}