import 'package:Lotie_Flutter/animatable/BaseAnimatableValue.dart';
import 'package:Lotie_Flutter/animation/KeyframeAnimation.dart';
import 'package:Lotie_Flutter/animation/impl/GradientColorKeyframeAnimation.dart';
import 'package:Lotie_Flutter/animation/impl/StaticKeyframeAnimation.dart';
import 'package:Lotie_Flutter/model/GradientColor.dart';
import 'package:Lotie_Flutter/model/Scene.dart';
import 'package:Lotie_Flutter/parser/Parser.dart';


class AnimatableGradientColorValue extends BaseAnimatableValue<GradientColor, GradientColor> {

  static final AnimatableValueParser _parser = new AnimatableValueParser<GradientColor>();

  AnimatableGradientColorValue._(GradientColor initialValue, Scene scene)
      : super(initialValue, scene: scene);

  factory AnimatableGradientColorValue(dynamic map, double scale) {
    final GradientColorParser gradienParser = new GradientColorParser(map['p']);
    KeyframeGroup<GradientColor> keyframeGroup = _parser.parse(map, gradienParser, scale);
    return new AnimatableGradientColorValue._(keyframeGroup.initialValue, keyframeGroup.scene);
  }

  @override
  KeyframeAnimation<GradientColor> createAnimation() {
    return hasAnimation ? new GradientColorKeyframeAnimation(scene) :
                          new StaticKeyframeAnimation(initialValue);
  }
  
}
