import 'package:Lotie_Flutter/src/animatables.dart';
import 'package:Lotie_Flutter/src/elements/shapes.dart';
import 'package:Lotie_Flutter/src/parsers/element_parsers.dart';
import 'package:Lotie_Flutter/src/values.dart';

class ShapePath extends Shape {
  final int _index;
  final AnimatableShapeValue _shapePath;

  ShapePath.fromMap(dynamic map, double scale)
      : _index = map['ind'],
        _shapePath = new AnimatableShapeValue.fromMap(map['ke'], scale),
        super.fromMap(map);
}

class ShapeTrimPath extends Shape {

  final ShapeTrimPathType _type;
  final AnimatableDoubleValue _start;
  final AnimatableDoubleValue _end;
  final AnimatableDoubleValue _offset;

  ShapeTrimPath.fromMap(dynamic map, double scale)
      : _type = parseShapeTrimPathType(map),
        _start = new AnimatableDoubleValue.fromMap(map['s'], scale),
        _end = new AnimatableDoubleValue.fromMap(map['e'], scale),
        _offset = new AnimatableDoubleValue.fromMap(map['o'], scale),
        super.fromMap(map);
}

class MergePaths extends Shape {
  final MergePathsMode _mode;

  MergePaths.fromMap(dynamic map, double scale)
      : _mode = parseMergePathsMode(map),
        super.fromMap(map);
}