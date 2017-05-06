import 'package:Lotie_Flutter/animatable/AnimatableValue.dart';
import 'package:Lotie_Flutter/animatable/impl/AnimatableDoubleValue.dart';
import 'package:Lotie_Flutter/animation/BaseKeyframeAnimation.dart';
import 'package:Lotie_Flutter/animation/KeyframeAnimation.dart';
import 'package:Lotie_Flutter/model/AnimationValues.dart';
import 'package:Lotie_Flutter/model/Keyframe.dart';
import 'package:Lotie_Flutter/model/Scene.dart';

class AnimatableSplitDimensionPathValue implements AnimatableValue<PointF> {

  final AnimatableFloatValue _animatableXDimension;
  final AnimatableFloatValue _animatableYDimension;

  AnimatableSplitDimensionPathValue(this._animatableXDimension,
      this._animatableYDimension);

  @override
  BaseKeyframeAnimation<dynamic, PointF> createAnimation() {
    return new _SplitDimensionPathKeyframeAnimation(
        _animatableXDimension.createAnimation(),
        _animatableYDimension.createAnimation());
  }

  @override
  bool get hasAnimation =>
      _animatableXDimension.hasAnimation || _animatableYDimension.hasAnimation;
}


class _SplitDimensionPathKeyframeAnimation extends KeyframeAnimation<PointF> {
  final KeyframeAnimation<double> xAnimation;
  final KeyframeAnimation<double> yAnimation;


  _SplitDimensionPathKeyframeAnimation(this.xAnimation, this.yAnimation)
      : super(new Scene.empty());

  @override
  set progress(double progress) {
    xAnimation.progress = progress;
    yAnimation.progress = progress;
    listeners.forEach((listener) => listener());
  }


  @override
  PointF getValue(Keyframe<PointF> keyframe, double keyframeProgress) {
    return new PointF(xAnimation.value, yAnimation.value);
  }
}