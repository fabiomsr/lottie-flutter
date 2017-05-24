import 'package:Lotie_Flutter/src/animations.dart';
import 'package:Lotie_Flutter/src/drawing/drawing.dart';
import 'package:Lotie_Flutter/src/utils.dart';
import 'package:flutter/painting.dart';
import 'package:vector_math/vector_math_64.dart';

class FillDrawable extends AnimationDrawable {

  final PathFillType _fillType;
  final Paint _paint = new Paint()
    ..isAntiAlias = true;
  final List<PathContent> _paths = [];
  final KeyframeAnimation<Color> _colorAnimation;
  final KeyframeAnimation<int> _opacityAnimation;

  FillDrawable(String name, Repaint repaint, this._fillType,
      this._colorAnimation, this._opacityAnimation) : super(name, repaint) {

    if(_colorAnimation != null && _opacityAnimation != null) {
      addAnimation(_colorAnimation);
      addAnimation(_opacityAnimation);
    }
  }

  @override
  void setContents(List<Content> contentsBefore, List<Content> contentsAfter) {
    for (var content in contentsAfter) {
      if (content is PathContent) {
        _paths.add(content);
      }
    }
  }

  @override
  void addColorFilter(String layerName, String contentName,
      ColorFilter colorFilter) {
    _paint.colorFilter = colorFilter;
  }

  @override
  void draw(Canvas canvas, Size size, Matrix4 parentMatrix, int parentAlpha) {
    int alpha = calculateAlpha(parentAlpha, _opacityAnimation);
    _paint.color = _colorAnimation.value.withAlpha(alpha);

    Path path = new Path();
    for(var pathSection in _paths) {
      //TODO: Review this :?
      // Android version: path.add(path, parentMatrix)
      path.addPath(pathSection.path.transform(parentMatrix.storage), const Offset(0.0, 0.0));
    }

    canvas.drawPath(path, _paint);
  }

  @override
  Rect getBounds(Matrix4 parentMatrix) {

    Path path = new Path();
    for(var pathSection in _paths) {
      //TODO: Review this :?
      // Android version: path.add(path, parentMatrix)
      path.addPath(pathSection.path.transform(parentMatrix.storage), const Offset(0.0, 0.0));
    }

    Rect outBounds = new Rect.fromLTRB(0.0, 0.0, 0.0, 0.0);
    //TODO: computeBounds is not expose
    //path.computeBounds(outBounds, false);
    return new Rect.fromLTRB(outBounds.left - 1,
        outBounds.top - 1, outBounds.right + 1,
        outBounds.bottom + 1);
  }

}


