import 'dart:math';
import 'package:Lotie_Flutter/src/animations.dart';
import 'package:Lotie_Flutter/src/drawing/drawing.dart';
import 'package:Lotie_Flutter/src/utils.dart';
import 'package:Lotie_Flutter/src/values.dart';
import 'package:flutter/painting.dart';
import 'package:vector_math/vector_math_64.dart';

abstract class FillDrawable extends AnimationDrawable {
  final Paint _paint = new Paint()..isAntiAlias = true;
  final PathFillType _fillType;
  final List<PathContent> _paths = [];
  final KeyframeAnimation<int> _opacityAnimation;

  FillDrawable(
      String name, Repaint repaint, this._opacityAnimation, this._fillType)
      : super(name, repaint) {
    if (_opacityAnimation != null) {
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
  Rect getBounds(Matrix4 parentMatrix) {
    Path path = _createPathFromSection(parentMatrix);
    Rect outBounds = new Rect.fromLTRB(0.0, 0.0, 0.0, 0.0);
    //TODO: computeBounds method is not expose
    //path.computeBounds(outBounds, false);
    return new Rect.fromLTRB(outBounds.left - 1, outBounds.top - 1,
        outBounds.right + 1, outBounds.bottom + 1);
  }

  Path _createPathFromSection(Matrix4 transform) {
    Path path = new Path();
    for (var pathSection in _paths) {
      addPathToPath(path, pathSection.path, transform);
    }

    return path;
  }
}

class ShapeFillDrawable extends FillDrawable {
  final KeyframeAnimation<Color> _colorAnimation;

  ShapeFillDrawable(
      String name,
      Repaint repaint,
      KeyframeAnimation<int> opacityAnimation,
      PathFillType fillType,
      this._colorAnimation)
      : super(name, repaint, opacityAnimation, fillType) {
    if (_colorAnimation != null) {
      addAnimation(_colorAnimation);
    }
  }

  @override
  void addColorFilter(
      String layerName, String contentName, ColorFilter colorFilter) {
    _paint.colorFilter = colorFilter;
  }

  @override
  void draw(Canvas canvas, Size size, Matrix4 parentMatrix, int parentAlpha) {
    int alpha = calculateAlpha(parentAlpha, _opacityAnimation);
    _paint.color = _colorAnimation.value.withAlpha(alpha);

    Path path = _createPathFromSection(parentMatrix);
    path.fillType = _fillType;

    canvas.drawPath(path, _paint);
  }
}

class GradientFillDrawable extends FillDrawable {
  final GradientType _gradientType;
  final KeyframeAnimation<GradientColor> _gradientColorAnimation;
  final KeyframeAnimation<Offset> _startPointAnimation;
  final KeyframeAnimation<Offset> _endPointAnimation;

  GradientFillDrawable(
    String name,
    Repaint repaint,
    KeyframeAnimation<int> opacityAnimation,
    PathFillType fillType,
    this._gradientType,
    this._gradientColorAnimation,
    this._startPointAnimation,
    this._endPointAnimation,
  )
      : super(name, repaint, opacityAnimation, fillType) {
    addAnimation(_gradientColorAnimation);
    addAnimation(_startPointAnimation);
    addAnimation(_endPointAnimation);
  }

  @override
  void draw(Canvas canvas, Size size, Matrix4 parentMatrix, int parentAlpha) {
    final path = _createPathFromSection(parentMatrix);
    path.fillType = _fillType;


    // TODO computeBounds
    final bounds = new Rect.fromLTRB(0.0, 0.0, 0.0, 0.0);
    //path.computeBounds(boundsRect, false);

    _paint
      ..shader = createGradientShader(_gradientColorAnimation.value,
          _gradientType, _startPointAnimation.value, _endPointAnimation.value,
          bounds)
      ..color = _paint.color
          .withAlpha(calculateAlpha(parentAlpha, _opacityAnimation));

    canvas.drawPath(path, _paint);
  }
}
