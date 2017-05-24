import 'package:Lotie_Flutter/src/animations.dart';
import 'package:Lotie_Flutter/src/drawing/drawing.dart';
import 'package:Lotie_Flutter/src/values.dart';

///
/// TrimPathDrawable
///
class TrimPathDrawable extends AnimationDrawable {

  final ShapeTrimPathType _type;
  final List<OnValueChanged> _listeners = [];
  final BaseKeyframeAnimation<dynamic, double> _startAnimation;
  final BaseKeyframeAnimation<dynamic, double> _endAnimation;
  final BaseKeyframeAnimation<dynamic, double> _offsetAnimation;

  ShapeTrimPathType get type => _type;

  double get start => _startAnimation.value;

  double get end => _endAnimation.value;

  double get offset => _offsetAnimation.value;

  TrimPathDrawable(String name, Repaint repaint, this._type,
      this._startAnimation,
      this._endAnimation, this._offsetAnimation)
      : super(name, repaint) {
    addAnimation(_startAnimation);
    addAnimation(_endAnimation);
    addAnimation(_offsetAnimation);
  }

  @override
  void onValueChanged() {
    _listeners.forEach((listener) => listener());
  }

  void addListener(OnValueChanged listener) {
    _listeners.add(listener);
  }
}
