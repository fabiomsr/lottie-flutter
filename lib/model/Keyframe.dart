import 'package:Lotie_Flutter/animatable/AnimatableValue.dart';
import 'package:Lotie_Flutter/parser/Parser.dart';
import 'package:flutter/animation.dart';
import 'package:flutter/painting.dart';

class Keyframe<T> {
  static const int MAX_CP_VALUE = 100;

  double startFrame;
  double endFrame;
  int _durationFrames;
  T _startValue;
  T _endValue;
  Curve _curve;

  Keyframe._();

  double get startProgress => startFrame / _durationFrames;

  double get endProgress => endFrame == null ? 1 : endFrame / _durationFrames;

  bool get isStatic => _curve == null;

  T get startValue => _startValue;

  T get endValue => _endValue;

  Curve get curve => _curve;

  bool containsProgress(double progress) =>
      progress >= startProgress && progress <= endProgress;

  Keyframe.fromMap(Map<String, dynamic> map, Parser<T> parser, double scale) {
    if (map.containsKey('t')) {
      _startValue = parser.parse(map, scale);
      _endValue = _startValue;
      return;
    }

    startFrame = map['t'];
    _startValue = parser.parse(map['s'], scale);
    _endValue = parser.parse(map['e'], scale);

    if (map['h'] == 1) {
      _endValue = _startValue;
      _curve = Curves.linear;
    } else if (map.containsKey('o')) {
      final double x1 = _clamp(map['o']['x'] * scale) / scale;
      final double y1 = _clamp(map['o']['y'] * scale) / scale;
      final double x2 = _clamp(map['i']['x'] * scale) / scale;
      final double y2 = _clamp(map['i']['y'] * scale) / scale;
      _curve = new Cubic(x1, y1, x2, y2);
    } else {
      _curve = Curves.linear;
    }
  }

  double _clamp(num value) => value.clamp(-MAX_CP_VALUE, MAX_CP_VALUE);

  @override
  String toString() {
    return 'Keyframe{ _durationFrames: $_durationFrames,'
        ' _startFrame: $startFrame, _endFrame: $endFrame,'
        ' _startValue: $_startValue, _endValue: $_endValue,'
        ' _curve: $_curve}';
  }

}

