import 'package:Lotie_Flutter/model/Keyframe.dart';
import 'package:Lotie_Flutter/parser/Parser.dart';

class Scene<T> {

  List<Keyframe<T>> _keyframes;

  List<Keyframe<T>> get keyframes => _keyframes;

  Keyframe<T> get firstKeyframe => _keyframes.first;

  Keyframe<T> get lastKeyframe => _keyframes.last;

  bool get isEmpty => _keyframes.isEmpty;

  bool get hasAnimation => _keyframes.isNotEmpty;


  Scene(this._keyframes) {
    _joinKeyframes();
  }

  Scene.empty() : this._keyframes = new List(0);

  Scene.fromMap(dynamic map, Parser<T> parser, scale) {
    if (map == null || !hasKeyframes(map)) {
      this._keyframes = new List(0);
    }

    List rawKeyframes = map['k'];
    if (rawKeyframes.isEmpty) {
      this._keyframes = new List(0);
    }

    this._keyframes = rawKeyframes.map((rawKeyframe) =>
                                      new Keyframe.fromMap(rawKeyframe, parser, scale))
                                  .toList();
    _joinKeyframes();
  }

  //
  //  The json doesn't include end frames. The data can be taken from the start frame of the next
  //  keyframe though.
  //
  void _joinKeyframes() {
    final int length = _keyframes.length;

    for (int i = 0; i < length - 1; i++) {
      // In the json, the keyframes only contain their starting frame.
      _keyframes[i].endFrame = _keyframes[i + 1].startFrame;
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

bool hasKeyframes(dynamic map) {
  if (map is List) {
  return false;
  }

  var first = map[0];

  return first is Map && first.containsKey('t');
}