import 'package:Lotie_Flutter/animation/BaseKeyframeAnimation.dart';

abstract class AnimatableValue<A> {

  BaseKeyframeAnimation<dynamic, A> createAnimation();

  bool get hasAnimation;

}



