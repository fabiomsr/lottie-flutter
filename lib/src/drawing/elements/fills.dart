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
    Path path = _createPathFromSection(parentMatrix);
    path.fillType = _fillType;

    _paint
      ..shader = createGradientShader()
      ..color = _paint.color
          .withAlpha(calculateAlpha(parentAlpha, _opacityAnimation));

    canvas.drawPath(path, _paint);
  }

  Shader createGradientShader() {
    final startPoint = _startPointAnimation.value;
    final endPoint = _endPointAnimation.value;

    // TODO computeBounds
    //path.computeBounds(boundsRect, false);
    final bounds = new Rect.fromLTRB(0.0, 0.0, 0.0, 0.0);

    double x0 = bounds.left + bounds.width / 2 + startPoint.dx;
    double y0 = bounds.top + bounds.height / 2 + startPoint.dy;
    double x1 = bounds.left + bounds.width / 2 + endPoint.dx;
    double y1 = bounds.top + bounds.height / 2 + endPoint.dy;

    return _gradientType == GradientType.Linear
        ? _createLinearGradientShader(x0, y0, x1, y1, bounds)
        : _createRadialGradientShader(x0, y0, x1, y1, bounds);
  }

  Shader _createLinearGradientShader(
      double x0, double y0, double x1, double y1, Rect bounds) {
    final gradientColor = _gradientColorAnimation.value;
    return new LinearGradient(
      begin: new FractionalOffset(x0, y0),
      end: new FractionalOffset(x1, y1),
      colors: gradientColor.colors,
      stops: gradientColor.positions,
    )
        .createShader(bounds);
  }

  Shader _createRadialGradientShader(
      double x0, double y0, double x1, double y1, Rect bounds) {
    final gradientColor = _gradientColorAnimation.value;
    return new RadialGradient(
      center: new FractionalOffset(x0, y0),
      radius: sqrt(hypot(x1 - x0, y1 - y0)),
      colors: gradientColor.colors,
      stops: gradientColor.positions,
    )
        .createShader(bounds);
  }
}
