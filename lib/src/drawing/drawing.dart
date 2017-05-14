import 'package:flutter/rendering.dart' show Canvas, ColorFilter, Matrix4, Rect, Size;

abstract class Content {

  String _name;

  String get name => _name;

  void setContents(List<Content> contentsBefore, List<Content> contentsAfter);
}

abstract class DrawingContent implements Content{
  void draw(Canvas canvas, Size size, Matrix4 parentMatrix, int parentAlpha);

  Rect getBounds(Matrix4 parentMatrix);

  void addColorFilter(String layerName, String contentName, ColorFilter colorFilter);
}
