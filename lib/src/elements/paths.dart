import 'package:lottie_flutter/src/animatables.dart';
import 'package:lottie_flutter/src/drawing/drawing.dart';
import 'package:lottie_flutter/src/drawing/elements/paths.dart';
import 'package:lottie_flutter/src/drawing/elements/shapes.dart';
import 'package:lottie_flutter/src/elements/shapes.dart';
import 'package:lottie_flutter/src/parsers/element_parsers.dart';
import 'package:lottie_flutter/src/values.dart';

class ShapePath extends Shape {
  final int _index;
  final AnimatableShapeValue _shapePath;

  ShapePath.fromMap(dynamic map, double scale, double durationFrames)
      : _index = map['ind'],
        _shapePath =
            new AnimatableShapeValue.fromMap(map['ks'], scale, durationFrames),
        super.fromMap(map);

  @override
  AnimationDrawable toDrawable(Repaint repaint) =>
      new ShapeDrawable(name, repaint, _shapePath.createAnimation());
}

class ShapeTrimPath extends Shape {
  final ShapeTrimPathType _type;
  final AnimatableDoubleValue _start;
  final AnimatableDoubleValue _end;
  final AnimatableDoubleValue _offset;

  ShapeTrimPath.fromMap(dynamic map, double scale, double durationFrames)
      : _type = parseShapeTrimPathType(map),
        _start =
            new AnimatableDoubleValue.fromMap(map['s'], 1.0, durationFrames),
        _end = new AnimatableDoubleValue.fromMap(map['e'], 1.0, durationFrames),
        _offset =
            new AnimatableDoubleValue.fromMap(map['o'], 1.0, durationFrames),
        super.fromMap(map);

  @override
  AnimationDrawable toDrawable(Repaint repaint) => new TrimPathDrawable(
      name,
      repaint,
      _type,
      _start.createAnimation(),
      _end.createAnimation(),
      _offset.createAnimation());
}

class MergePaths extends Shape {
  final MergePathsMode _mode;

  MergePaths.fromMap(dynamic map, double scale)
      : _mode = parseMergePathsMode(map),
        super.fromMap(map);

  @override
  AnimationDrawable toDrawable(Repaint repaint) =>
      new MergePathsDrawable(name, repaint, _mode);
}
