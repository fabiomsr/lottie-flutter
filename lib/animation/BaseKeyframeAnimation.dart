import 'package:Lotie_Flutter/model/Keyframe.dart';
import 'package:Lotie_Flutter/model/Scene.dart';
import 'package:meta/meta.dart';

typedef OnValueChanged();

abstract class BaseKeyframeAnimation<K, A> {

  final List<OnValueChanged> listeners = new List();
  bool isDiscrete = false;

  final Scene<K> scene;
  double _progress = 0.0;

  Keyframe<K> cachedKeyframe;

  BaseKeyframeAnimation(this.scene);

  void addUpdateListener(OnValueChanged listener) {
    listeners.add(listener);
  }

  double get startDelayProgress => scene.isEmpty ? 0.0 : scene.firstKeyframe.startProgress;

  double get endProgress => scene.isEmpty ? 1.0 : scene.lastKeyframe.endProgress;

  set progress(double progress) {
    if(progress < startDelayProgress){
      progress = 0.0;
    } else if (progress > endProgress) {
      progress = 1.0;
    }

    if(progress == _progress) {
      return;
    }

    _progress = progress;

    listeners.forEach((it) => it());
  }

  Keyframe<K> get currentKeyframe {
    if(scene.isEmpty) {
      throw new StateError("There are no keyframes");
    }

    if(cachedKeyframe != null && cachedKeyframe.containsProgress(_progress)) {
      return cachedKeyframe;
    }

    if(_progress < scene.firstKeyframe.startProgress) {
      return cachedKeyframe = scene.firstKeyframe;
    }

    for (var keyframe in scene.keyframes) {
      if(!keyframe.containsProgress(_progress)) {
        cachedKeyframe = keyframe;
      }
    }

    return cachedKeyframe;
  }

  double get currentKeyframeProgress {
    if(isDiscrete) {
      return 0.0;
    }

    final Keyframe keyframe = currentKeyframe;

    if(keyframe.isStatic) {
      return 0.0;
    }

    double progressIntoFrame = _progress - keyframe.startProgress;
    double keyframeProgress = keyframe.endProgress - keyframe.startProgress;

    return keyframe.curve.transform(progressIntoFrame / keyframeProgress);
  }


  A get value {
    return getValue(currentKeyframe, currentKeyframeProgress);
  }

  // keyframeProgress will be [0, 1] unless the interpolator has overshoot in which case, this
  // should be able to handle values outside of that range.
  @protected
  A getValue(Keyframe<K> keyframe, double keyframeProgress);

}