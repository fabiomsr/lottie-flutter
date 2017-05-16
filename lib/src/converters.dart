import 'package:Lotie_Flutter/src/drawing/drawing_layers.dart';
import 'package:Lotie_Flutter/src/layers.dart';
import 'package:Lotie_Flutter/src/shapes.dart';
import 'package:Lotie_Flutter/src/transform.dart';

Shape shapeFromMap(dynamic rawShape, double scale) {
  switch (rawShape['ty']) {
    case 'gr':
      return new ShapeGroup.fromMap(rawShape, scale);
    case 'st':
      return new ShapeStroke(rawShape, scale);
    case 'gs':
      return new GradientStroke.fromMap(rawShape, scale);
    case 'fl':
      return new ShapeFill(rawShape, scale);
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

