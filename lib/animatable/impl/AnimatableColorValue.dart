import 'package:Lotie_Flutter/animatable/BaseAnimatableValue.dart';
import 'package:Lotie_Flutter/animation/KeyframeAnimation.dart';
import 'package:Lotie_Flutter/animation/impl/ColorKeyframeAnimation.dart';
import 'package:Lotie_Flutter/animation/impl/StaticKeyframeAnimation.dart';
import 'package:Lotie_Flutter/model/Scene.dart';
import 'package:Lotie_Flutter/parser/Parser.dart';
import 'package:flutter/material.dart';

class AnimatableColorValue extends BaseAnimatableValue<Color, Color> {

  static final AnimatableValueParser _parser = new AnimatableValueParser<Color>();

  AnimatableColorValue._(Color initialValue, Scene<Color> scene) : super(initialValue, scene: scene);

  factory AnimatableColorValue(dynamic map, double scale) {
    KeyframeGroup<Color> keyframeGroup = _parser.parse(map, Parsers.colorParser, scale);
    return new AnimatableColorValue._(keyframeGroup.initialValue, keyframeGroup.scene);
  }

  @override
  KeyframeAnimation<Color> createAnimation() {
    return hasAnimation ? new ColorKeyframeAnimation(scene) :
                          new StaticKeyframeAnimation(initialValue);
  }


}


