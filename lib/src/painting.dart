import 'package:Lotie_Flutter/src/animatables.dart';


enum MaskMode { Add, Subtract, Intersect, Unknown }

class Mask {
  final MaskMode _mode;
  final AnimatableShapeValue _path;

  MaskMode get mode => _mode;

  AnimatableShapeValue get path => _path;

  Mask.fromMap(dynamic map, double scale, double durationFrames)
      : _mode = calculateMode(map['mode']),
        _path = new AnimatableShapeValue.fromMap(map, scale, durationFrames);

  static MaskMode calculateMode(String rawMode) {
    switch(rawMode) {
      case 'a': return MaskMode.Add;
      case 's': return MaskMode.Subtract;
      case 'i': return MaskMode.Intersect;
      default: return MaskMode.Unknown;
    }
  }

}

