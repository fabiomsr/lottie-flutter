import 'package:Lotie_Flutter/src/elements/fills.dart';
import 'package:Lotie_Flutter/src/elements/paths.dart';
import 'package:Lotie_Flutter/src/elements/shapes.dart';
import 'package:Lotie_Flutter/src/elements/strokes.dart';
import 'package:Lotie_Flutter/src/elements/transforms.dart';

class ShapeGroup extends Shape {
  final List<Shape> _shapes;

  List<Shape> get shapes => _shapes;

  ShapeGroup.fromMap(dynamic map, double scale, double durationFrames)
      : _shapes = parseRawShapes(map['it'], scale, durationFrames),
        super.fromMap(map);

  static List<Shape> parseRawShapes(List rawShapes, double scale, double durationFrames) =>
      rawShapes.map((rawShape) => shapeFromMap(rawShape, scale, durationFrames))
          .toList();
}

Shape shapeFromMap(dynamic rawShape, double scale, double durationFrames) {
  switch (rawShape['ty']) {
    case 'gr':
      return new ShapeGroup.fromMap(rawShape, scale, durationFrames);
    case 'st':
      return new ShapeStroke.fromMap(rawShape, scale, durationFrames);
    case 'gs':
      return new GradientStroke.fromMap(rawShape, scale, durationFrames);
    case 'fl':
      return new ShapeFill.fromMap(rawShape, scale, durationFrames);
    case 'gf':
      return new GradientFill.fromMap(rawShape, scale, durationFrames);
    case 'tr':
      return new AnimatableTransform(rawShape, scale, durationFrames);
    case 'sh':
      return new ShapePath.fromMap(rawShape, scale, durationFrames);
    case 'el':
      return new CircleShape.fromMap(rawShape, scale, durationFrames);
    case 'rc':
      return new RectangleShape.fromMap(rawShape, scale, durationFrames);
    case 'tm':
      return new ShapeTrimPath.fromMap(rawShape, scale, durationFrames);
    case 'sr':
      return new PolystarShape.fromMap(rawShape, scale, durationFrames);
    case 'mm':
      return new MergePaths.fromMap(rawShape, scale);
    default:
      return new UnknownShape();
  }
}

