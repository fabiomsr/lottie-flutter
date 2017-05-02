import 'package:Lotie_Flutter/animation/KeyframeAnimation.dart';
import 'package:Lotie_Flutter/model/Keyframe.dart';
import 'package:Lotie_Flutter/model/Scene.dart';

class StaticKeyframeAnimation<T> extends KeyframeAnimation<T> {

  final T _initialValue;

  StaticKeyframeAnimation(this._initialValue) : super(new Scene.empty());

  @override
  set progress(double progress) {
    // Do nothing
  }

  @override
  T getValue(Keyframe<T> keyframe, double keyframeProgress) {
    return _initialValue;
  }

}
