import 'package:Lotie_Flutter/animation/KeyframeAnimation.dart';
import 'package:Lotie_Flutter/model/GradientColor.dart';
import 'package:Lotie_Flutter/model/Keyframe.dart';
import 'package:Lotie_Flutter/model/Scene.dart';

class GradientColorKeyframeAnimation extends KeyframeAnimation<GradientColor>{
  GradientColor _gradientColor;

  GradientColorKeyframeAnimation(Scene<GradientColor> scene) : super(scene) {
    GradientColor startValue = scene.firstKeyframe.startValue;
    int length = startValue == null ? 0 : startValue.length;
    _gradientColor = new GradientColor(new List(length), new List(length));
  }

  @override
  GradientColor getValue(Keyframe<GradientColor> keyframe, double keyframeProgress) {
    return _gradientColor..lerp(keyframe.startValue, keyframe.endValue, keyframeProgress);
  }
}
