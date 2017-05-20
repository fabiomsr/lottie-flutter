import 'package:Lotie_Flutter/src/elements/fills.dart';
import 'package:Lotie_Flutter/src/elements/paths.dart';
import 'package:Lotie_Flutter/src/elements/shapes.dart';
import 'package:Lotie_Flutter/src/elements/strokes.dart';
import 'package:Lotie_Flutter/src/elements/transforms.dart';

class ShapeGroup extends Shape {
  final List<Shape> _shapes;

  List<Shape> get shapes => _shapes;

  ShapeGroup.fromMap(dynamic map, double scale)
      : _shapes = parseRawShapes(map['it'], scale),
        super.fromMap(map);

  static List<Shape> parseRawShapes(List rawShapes, double scale) =>
      rawShapes.map((rawShape) => shapeFromMap(rawShape, scale))
          .toList();
}

Shape shapeFromMap(dynamic rawShape, double scale) {
  switch (rawShape['ty']) {
    case 'gr':
      return new ShapeGroup.fromMap(rawShape, scale);
    case 'st':
      return new ShapeStroke.fromMap(rawShape, scale);
    case 'gs':
      return new GradientStroke.fromMap(rawShape, scale);
    case 'fl':
      return new ShapeFill.fromMap(rawShape, scale);
    case 'gf':
      return new GradientFill.fromMap(rawShape, scale);
    case 'tr':
      return new AnimatableTransform(rawShape, scale);
    case 'sh':
      return new ShapePath.fromMap(rawShape, scale);
    case 'el':
      return new CircleShape.fromMap(rawShape, scale);
    case 'rc':
      return new RectangleShape.fromMap(rawShape, scale);
    case 'tm':
      return new ShapeTrimPath.fromMap(rawShape, scale);
    case 'sr':
      return new PolystarShape.fromMap(rawShape, scale);
    case 'mm':
      return new MergePaths.fromMap(rawShape, scale);
    default:
      return new UnknownShape();
  }
}

