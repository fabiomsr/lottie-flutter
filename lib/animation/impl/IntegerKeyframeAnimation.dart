import 'package:Lotie_Flutter/animation/KeyframeAnimation.dart';
import 'package:Lotie_Flutter/model/Keyframe.dart';
import 'package:Lotie_Flutter/model/Scene.dart';
import 'package:Lotie_Flutter/utils/Maths.dart';

class IntegerKeyframeAnimation extends KeyframeAnimation<int>{
  IntegerKeyframeAnimation(Scene<int> scene) : super(scene);

  @override
  int getValue(Keyframe<int> keyframe, double keyframeProgress) {
    if(keyframe.startValue == null || keyframe.endValue == null) {
      throw new StateError("Missing values for keyframe.");
    }

    return lerpInt(keyframe.startValue, keyframe.endValue, keyframeProgress).toInt();
  }
}
