import 'package:Lotie_Flutter/animation/KeyframeAnimation.dart';
import 'package:Lotie_Flutter/model/Keyframe.dart';
import 'package:Lotie_Flutter/model/Scene.dart';
import 'package:Lotie_Flutter/utils/Maths.dart';

class DoubleKeyframeAnimation extends KeyframeAnimation<double> {
  DoubleKeyframeAnimation(Scene<double> scene) : super(scene);

  @override
  double getValue(Keyframe<double> keyframe, double keyframeProgress) {
    if(keyframe.startValue == null || keyframe.endValue == null) {
      throw new StateError("Missing values for keyframe.");
    }

    return lerp(keyframe.startValue, keyframe.endValue, keyframeProgress);
  }

}
