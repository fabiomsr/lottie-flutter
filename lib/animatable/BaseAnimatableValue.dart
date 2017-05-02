import 'package:Lotie_Flutter/animatable/AnimatableValue.dart';
import 'package:Lotie_Flutter/model/Scene.dart';

abstract class BaseAnimatableValue<V, O> implements AnimatableValue<O> {

  final V initialValue;
  Scene<V> scene;

  BaseAnimatableValue(this.initialValue, {this.scene } ) {
    this.scene = scene ?? new Scene.empty();
  }

  bool get hasAnimation => scene.hasAnimation;

  @override
  String toString() {
    return 'BaseAnimatableValue{initialValue: $initialValue, scene: $scene}';
  }

}