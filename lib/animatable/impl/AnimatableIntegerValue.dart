import 'package:Lotie_Flutter/animatable/BaseAnimatableValue.dart';
import 'package:Lotie_Flutter/animation/KeyframeAnimation.dart';
import 'package:Lotie_Flutter/animation/impl/IntegerKeyframeAnimation.dart';
import 'package:Lotie_Flutter/animation/impl/StaticKeyframeAnimation.dart';
import 'package:Lotie_Flutter/model/Scene.dart';
import 'package:Lotie_Flutter/parser/Parser.dart';

class AnimatableIntegerValue extends  BaseAnimatableValue<int, int>{

  static final AnimatableValueParser _parser = new AnimatableValueParser<int>();

  AnimatableIntegerValue._({int initialValue = 100, Scene<int> scene})
      : super(initialValue, scene: scene);

  factory AnimatableIntegerValue(dynamic map, double scale) {
    KeyframeGroup<int> keyframeGroup = _parser.parse(map, Parsers.intParser, scale);
    return new AnimatableIntegerValue._(
        initialValue: keyframeGroup.initialValue, scene: keyframeGroup.scene);
  }

  @override
  KeyframeAnimation<int> createAnimation() {
    return hasAnimation ? new IntegerKeyframeAnimation(scene) :
                          new StaticKeyframeAnimation(initialValue);
  }
}

