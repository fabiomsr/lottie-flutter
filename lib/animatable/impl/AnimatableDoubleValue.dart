import 'package:Lotie_Flutter/animatable/BaseAnimatableValue.dart';
import 'package:Lotie_Flutter/animation/KeyframeAnimation.dart';
import 'package:Lotie_Flutter/animation/impl/FloatKeyframeAnimation.dart';
import 'package:Lotie_Flutter/animation/impl/StaticKeyframeAnimation.dart';
import 'package:Lotie_Flutter/model/Scene.dart';
import 'package:Lotie_Flutter/parser/Parser.dart';

class AnimatableFloatValue extends BaseAnimatableValue<double, double> {

  static final AnimatableValueParser _parser = new AnimatableValueParser<double>();

  AnimatableFloatValue._({double initialValue = 0.0, Scene<double> scene})
      : super(initialValue, scene: scene);

  factory AnimatableFloatValue(dynamic map, double scale) {
    KeyframeGroup<double> keyframeGroup = _parser.parse(map, Parsers.doubleParser, scale);
    return new AnimatableFloatValue._(
        initialValue: keyframeGroup.initialValue, scene: keyframeGroup.scene);
  }

  @override
  KeyframeAnimation<double> createAnimation() {
    return hasAnimation ? new DoubleKeyframeAnimation(scene) :
                          new StaticKeyframeAnimation(initialValue);
  }

}
