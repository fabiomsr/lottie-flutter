import 'package:Lotie_Flutter/src/animations.dart';
import 'package:flutter/rendering.dart' show Canvas, ColorFilter, Matrix4, Path, Rect, Size;

abstract class Content {
  String get name;

  void setContents(List<Content> contentsBefore, List<Content> contentsAfter);
}

abstract class Drawable implements Content{
  void draw(Canvas canvas, Size size, Matrix4 parentMatrix, int parentAlpha);

  Rect getBounds(Matrix4 parentMatrix);

  void addColorFilter(String layerName, String contentName, ColorFilter colorFilter);
}


typedef Repaint();

abstract class AnimationDrawable implements Drawable {

  final String _name;
  final Repaint _repaint;
  final List<BaseKeyframeAnimation<dynamic, dynamic>> _animations = [];

  @override
  String get name => _name;

  List<BaseKeyframeAnimation<dynamic, dynamic>> get animations => _animations;

  AnimationDrawable(this._name, this._repaint);

  void addAnimation(BaseKeyframeAnimation<dynamic, dynamic> animation) {
    _animations.add(animation);
    animation.addListener(onValueChanged);
  }

  void invalidate() {
    _repaint();
  }

  void onValueChanged() {
    invalidate();
  }

  @override
  void addColorFilter(String layerName, String contentName,
      ColorFilter colorFilter) {  }

  @override
  void draw(Canvas canvas, Size size, Matrix4 parentMatrix, int parentAlpha) {}

  @override
  Rect getBounds(Matrix4 parentMatrix) => new Rect.fromLTRB(0.0, 0.0, 0.0, 0.0);

  @override
  void setContents(List<Content> contentsBefore, List<Content> contentsAfter) {
  }
}

abstract class PathContent implements Content{
  Path get path;
}
