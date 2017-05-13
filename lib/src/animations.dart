
import 'package:Lotie_Flutter/src/utils.dart';
import 'package:Lotie_Flutter/src/values.dart';
import 'package:Lotie_Flutter/src/keyframes.dart';
import 'package:flutter/painting.dart' show Color, Offset;
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

abstract class KeyframeAnimation<T> extends BaseKeyframeAnimation<T, T> {

  KeyframeAnimation(Scene<T> scene): super(scene);

  void checkKeyframe(Keyframe keyframe) {
    if(keyframe.startValue == null || keyframe.endValue == null) {
      throw new StateError("Missing values for keyframe.");
    }
  }
}


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


class IntegerKeyframeAnimation extends KeyframeAnimation<int>{
  IntegerKeyframeAnimation(Scene<int> scene) : super(scene);

  @override
  int getValue(Keyframe<int> keyframe, double keyframeProgress) {
    checkKeyframe(keyframe);
    return lerpInt(keyframe.startValue, keyframe.endValue, keyframeProgress).toInt();
  }
}


class DoubleKeyframeAnimation extends KeyframeAnimation<double> {
  DoubleKeyframeAnimation(Scene<double> scene) : super(scene);

  @override
  double getValue(Keyframe<double> keyframe, double keyframeProgress) {
    checkKeyframe(keyframe);
    return lerp(keyframe.startValue, keyframe.endValue, keyframeProgress);
  }

}


class ColorKeyframeAnimation extends KeyframeAnimation<Color> {

  ColorKeyframeAnimation(Scene<Color> scene) : super(scene);

  @override
  Color getValue(Keyframe<Color> keyframe, double keyframeProgress) {
    checkKeyframe(keyframe);
    return GammaEvaluator.evaluate(keyframeProgress,
        keyframe.startValue, keyframe.endValue);
  }
}



class GradientColorKeyframeAnimation extends KeyframeAnimation<GradientColor>{
  GradientColor _gradientColor;

  GradientColorKeyframeAnimation(Scene<GradientColor> scene) : super(scene) {
    GradientColor startValue = scene.firstKeyframe.startValue;
    int length = startValue == null ? 0 : startValue.length;
    _gradientColor = new GradientColor(new List(length), new List(length));
  }

  @override
  GradientColor getValue(Keyframe<GradientColor> keyframe, double keyframeProgress) {
    return _gradientColor..lerpGradients(keyframe.startValue, keyframe.endValue, keyframeProgress);
  }
}


class PointKeyframeAnimation extends KeyframeAnimation<Offset>{

  PointKeyframeAnimation(Scene<Offset> scene) : super(scene);

  @override
  Offset getValue(Keyframe<Offset> keyframe, double keyframeProgress) {
    checkKeyframe(keyframe);

    Offset startPoint = keyframe.startValue;
    Offset endPoint = keyframe.endValue;

    return new Offset(startPoint.dx + keyframeProgress * (endPoint.dx - startPoint.dx),
        startPoint.dy + keyframeProgress * (endPoint.dy - startPoint.dy));
  }
}


class ScaleKeyframeAnimation extends KeyframeAnimation<Offset> {

  ScaleKeyframeAnimation(Scene<Offset> scene) : super(scene);

  @override
  Offset getValue(Keyframe<Offset> keyframe, double keyframeProgress) {
    checkKeyframe(keyframe);

    Offset startTransform = keyframe.startValue;
    Offset endTransform = keyframe.endValue;

    return new Offset(lerp(startTransform.dx, endTransform.dx, keyframeProgress),
        lerp(startTransform.dy, endTransform.dy, keyframeProgress));

  }
}


class ShapeKeyframeAnimation extends BaseKeyframeAnimation<ShapeData, Path> {

  ShapeKeyframeAnimation(Scene<ShapeData> scene) : super(scene);

  @override
  Path getValue(Keyframe<ShapeData> keyframe, double keyframeProgress) {
    final shape = new ShapeData.fromInterpolateBetween(
        keyframe.startValue, keyframe.endValue, keyframeProgress);
    return new Path.fromShape(shape);
  }
}


class PathKeyframeAnimation extends KeyframeAnimation<Offset> {

  PathKeyframe _pathMeasureKeyframe;
  //PathMeasure _pathMeasure;

  PathKeyframeAnimation(Scene<Offset> scene) : super(scene);

  @override
  Offset getValue(Keyframe<Offset> keyframe, double keyframeProgress) {
    PathKeyframe _pathKeyframe = keyframe;

    if(_pathKeyframe.path == null) {
      return keyframe.startValue;
    }


    //TODO: No PathMeasure in flutter sdk :(
    if(_pathKeyframe != _pathKeyframe) {
      // _pathMeasure = new PathMeasure(_pathKeyframe._path, false);
      _pathMeasureKeyframe = keyframe;
    }

    //pathMeasure.getPosTan(keyframeProgress * pathMeasure.length, pos, null);
    //point.set(pos[0],pos[1]);
    //return point;
    return const Offset(0.0, 0.0);
  }
}


class SplitDimensionPathKeyframeAnimation extends KeyframeAnimation<Offset> {
  final KeyframeAnimation<double> xAnimation;
  final KeyframeAnimation<double> yAnimation;


  SplitDimensionPathKeyframeAnimation(this.xAnimation, this.yAnimation)
      : super(new Scene.empty());

  @override
  set progress(double progress) {
    xAnimation.progress = progress;
    yAnimation.progress = progress;
    listeners.forEach((listener) => listener());
  }


  @override
  Offset getValue(Keyframe<Offset> keyframe, double keyframeProgress) {
    return new Offset(xAnimation.value, yAnimation.value);
  }
}










