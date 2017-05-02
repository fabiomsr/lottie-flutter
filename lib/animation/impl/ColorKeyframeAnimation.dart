import 'package:Lotie_Flutter/animation/KeyframeAnimation.dart';
import 'package:Lotie_Flutter/model/Keyframe.dart';
import 'package:Lotie_Flutter/model/Scene.dart';
import 'package:Lotie_Flutter/utils/GammaEvaluator.dart';
import 'package:flutter/material.dart';

class ColorKeyframeAnimation extends KeyframeAnimation<Color> {

  ColorKeyframeAnimation(Scene<Color> scene) : super(scene);

  @override
  Color getValue(Keyframe<Color> keyframe, double keyframeProgress) {
    if (keyframe.startValue == null || keyframe.endValue == null) {
      throw new StateError("Missing values for keyframe.");
    }

    return GammaEvaluator.evaluate(keyframeProgress,
        keyframe.startValue, keyframe.endValue);
  }
}
