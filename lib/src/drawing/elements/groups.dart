import 'dart:math';
import 'dart:ui';
import 'package:Lotie_Flutter/src/animations.dart';
import 'package:Lotie_Flutter/src/drawing/drawing.dart';
import 'package:Lotie_Flutter/src/elements/shapes.dart';
import 'package:Lotie_Flutter/src/utils.dart';
import 'package:Lotie_Flutter/src/values.dart';
import 'package:vector_math/vector_math_64.dart';

class DrawableGroup extends AnimationDrawable implements PathContent {
  List<PathContent> get paths => [];

  DrawableGroup(String name, Repaint repaint, List<Shape> shapes) : super(name, repaint);

  @override
  void setContents(List<Content> contentsBefore, List<Content> contentsAfter) {
    // TODO: implement setContents
  }

  @override
  void addColorFilter(String layerName, String contentName,
      ColorFilter colorFilter) {
    // TODO: implement addColorFilter
  }

  @override
  void draw(Canvas canvas, Size size, Matrix4 parentMatrix, int parentAlpha) {
    // TODO: implement draw
  }

  @override
  Rect getBounds(Matrix4 parentMatrix) {
    // TODO: implement getBounds
    return null;
  }


  Matrix4 get transformation => null;

  // TODO: implement path
  @override
  Path get path => null;
}



