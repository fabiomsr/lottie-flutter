import 'package:Lotie_Flutter/animation/BaseKeyframeAnimation.dart';
import 'package:Lotie_Flutter/model/Keyframe.dart';
import 'package:Lotie_Flutter/model/Scene.dart';

abstract class KeyframeAnimation<T> extends BaseKeyframeAnimation<T, T> {

  KeyframeAnimation(Scene<T> scene): super(scene);

}