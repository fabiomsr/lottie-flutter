import 'package:Lotie_Flutter/src/values.dart';
import 'package:Lotie_Flutter/src/parsers/parsers.dart';
import 'package:flutter/animation.dart' show Curve, Curves, Cubic;
import 'package:flutter/painting.dart' show Offset, Path;

class Keyframe<T> {
  static const double MAX_CP_VALUE = 100.0;

  int _startFrame;
  int _endFrame;
  double _durationFrames;
  T _startValue;
  T _endValue;
  Curve _curve;

  double get startProgress => _startFrame / _durationFrames;

  double get endProgress => _endFrame == null ? 1 : _endFrame / _durationFrames;

  bool get isStatic => _curve == null;

  int get startFrame => _startFrame;

  int get endFrame => _endFrame;

  T get startValue => _startValue;

  T get endValue => _endValue;

  Curve get curve => _curve;

  bool containsProgress(double progress) =>
      progress >= startProgress && progress <= endProgress;


  Keyframe([this._startFrame, this._endFrame, this._durationFrames,
    this._startValue, this._endValue]);

  Keyframe.fromMap(Map<String, dynamic> map, Parser<T> parser, double scale) {
    if (!map.containsKey('t')) {
      _startValue = parser.parse(map, scale);
      _endValue = _startValue;
      return;
    }

    _startFrame = map['t'];
    _startValue = map.containsKey('s') ?  parser.parse(map['s'], scale) : null;
    _endValue = map.containsKey('e')  ? parser.parse(map['e'], scale) : null;

    if (map['h'] == 1) {
      _endValue = _startValue;
      _curve = Curves.linear;
    } else if (map.containsKey('o')) {
      final double x1 = _clamp(map['o']['x'], -scale, scale) / scale;
      final double y1 = _clamp(map['o']['y'], -MAX_CP_VALUE, MAX_CP_VALUE) / scale;
      final double x2 = _clamp(map['i']['x'], -scale, scale) / scale;
      final double y2 = _clamp(map['i']['y'], -MAX_CP_VALUE, MAX_CP_VALUE) / scale;
      _curve = new Cubic(x1, y1, x2, y2);
    } else {
      _curve = Curves.linear;
    }
  }

  double _clamp(dynamic value, double min, double max) => parseMapToDouble(value).clamp(min, max);

  @override
  String toString() {
    return 'Keyframe{ _durationFrames: $_durationFrames,'
        ' _startFrame: $_startFrame, _endFrame: $_endFrame,'
        ' _startValue: $_startValue, _endValue: $_endValue,'
        ' _curve: $_curve}';
  }

}


class PathKeyframe extends Keyframe<Offset> {

  Path _path;

  Path get path => _path;

  PathKeyframe(int startFrame, int endFrame, double durationFrames,
      Offset startValue, Offset endValue)
      : super(startFrame, endFrame, durationFrames, startValue, endValue);

  PathKeyframe.fromMap(dynamic map, double scale) {
    Keyframe<Offset> keyframe = new Keyframe.fromMap(
        map, Parsers.pointFParser, scale);
    Offset cp1 = Parsers.pointFParser.parse(map['ti'], scale);
    Offset cp2 = Parsers.pointFParser.parse(map['to'], scale);

    bool equals = keyframe.endValue != null && keyframe.startValue != null &&
        keyframe.endValue.dx == keyframe.endValue.dy;
    if (!equals) {
      _path = createPath(keyframe.startValue, keyframe.startValue, cp1, cp2);
    }
  }

  Path createPath (Offset start, Offset end, Offset cp1, Offset cp2) {
    Path path = new Path();
    path.moveTo(start.dx, start.dy);

    if (cp1 != null && cp2 != null &&
        (cp1.distance != 0 || cp2.distance != 0)) {
      path.cubicTo(start.dx + cp1.dx, start.dy + cp1.dy,
          end.dx + cp2.dx, end.dy + cp2.dy,
          end.dx, end.dy);
    } else {
      path.lineTo(end.dx, end.dy);
    }

    return path;
  }

}


class Scene<T> {

  final List<Keyframe<T>> _keyframes;

  List<Keyframe<T>> get keyframes => _keyframes;

  Keyframe<T> get firstKeyframe => _keyframes.first;

  Keyframe<T> get lastKeyframe => _keyframes.last;

  bool get isEmpty => _keyframes.isEmpty;

  bool get hasAnimation => _keyframes.isNotEmpty;


  Scene(this._keyframes, [bool join = true]) {
    if(join) {
      _joinKeyframes();
    }
  }

  const Scene.empty() : this._keyframes = const [];

  Scene.fromMap(dynamic map, Parser<T> parser, scale)
      : _keyframes = parseKeyframes(map, parser, scale){
    if(_keyframes.isNotEmpty) {
      _joinKeyframes();
    }
  }

  static List<Keyframe> parseKeyframes(dynamic map, Parser parser,
      double scale) {
    if (map == null) {
      return const [];
    }

    var rawKeyframes = map['k'];
    if (!hasKeyframes(rawKeyframes)) {
      return const [];
    }

    return rawKeyframes.map((rawKeyframe) =>
    new Keyframe.fromMap(rawKeyframe, parser, scale))
        .toList();
  }

  //
  //  The json doesn't include end frames. The data can be taken from the start frame of the next
  //  keyframe though.
  //
  void _joinKeyframes() {
    final int length = _keyframes.length;

    for (int i = 0; i < length - 1; i++) {
      // In the json, the keyframes only contain their starting frame.
      _keyframes[i]._endFrame = _keyframes[i + 1]._startFrame;
    }

    if (_keyframes.last.startValue == null) {
      _keyframes.removeLast();
    }
  }

  @override
  String toString() {
    return 'Scene{keyframes: $_keyframes}';
  }

}


class KeyframeGroup<T> {
  final Scene scene;
  final T initialValue;

  KeyframeGroup(this.initialValue, this.scene);
}

bool hasKeyframes(dynamic json) {
  if (json == null || !(json is List)) {
    return false;
  }

  var first = json[0];

  return first is Map && first.containsKey('t');
}


