import 'dart:math';
import 'dart:ui';
import 'package:lottie_flutter/src/animations.dart';
import 'package:lottie_flutter/src/drawing/drawing.dart';
import 'package:lottie_flutter/src/drawing/elements/paths.dart';
import 'package:lottie_flutter/src/utils.dart';
import 'package:lottie_flutter/src/values.dart';


abstract class _PolygonDrawable extends AnimationDrawable
    implements PathContent {

  bool _isPathValid = false;
  TrimPathDrawable _trimPathDrawable;
  Path _path = new Path();

  _PolygonDrawable(String name, Repaint repaint) : super(name, repaint);

  Path get path {
    if (_isPathValid) {
      return _path;
    }


    createPath();

    if (_trimPathDrawable != null) {
      applyScaleTrimIfNeeded(
          _path, _trimPathDrawable.start, _trimPathDrawable.end,
          _trimPathDrawable.offset);
    }

    _isPathValid = true;
    return _path;
  }

  @override
  void invalidate() {
    _isPathValid = false;
    super.invalidate();
  }

  @override
  void setContents(List<Content> contentsBefore, List<Content> contentsAfter) {
    for (var content in contentsBefore) {
      if (content is TrimPathDrawable &&
          content.type == ShapeTrimPathType.Simultaneously) {
        _trimPathDrawable = content;
        _trimPathDrawable.addListener(onValueChanged);
      }
    }
  }

  void createPath();
}

///
/// CircleDrawable
///
class EllipseDrawable extends _PolygonDrawable {

  static const double CONTROL_POINT_PERCENTAGE = 0.55228;

  final BaseKeyframeAnimation _sizeAnimation;
  final BaseKeyframeAnimation _positionAnimation;

  EllipseDrawable(String name, Repaint repaint, this._sizeAnimation,
      this._positionAnimation) : super(name, repaint) {
    addAnimation(_sizeAnimation);
    addAnimation(_positionAnimation);
  }

  @override
  void createPath() {
    final size = _sizeAnimation.value;
    final halfWidth = size.dx / 2.0;
    final halfHeight = size.dy / 2.0;
    //TODO: handle bounds

    final controlPointWidth = halfWidth * CONTROL_POINT_PERCENTAGE;
    final controlPointHeight = halfHeight * CONTROL_POINT_PERCENTAGE;

    _path.reset();
    _path.moveTo(0.0, -halfHeight);
    _path.cubicTo(controlPointWidth, -halfHeight, halfWidth, controlPointHeight,
        halfWidth, 0.0);
    _path.cubicTo(
        halfWidth, controlPointHeight, controlPointWidth, halfHeight, 0.0,
        halfHeight);
    _path.cubicTo(
        -controlPointWidth, halfHeight, -halfWidth, controlPointHeight,
        -halfWidth, 0.0);
    _path.cubicTo(
        -halfWidth, -controlPointHeight, -controlPointWidth, -halfHeight, 0.0,
        -halfHeight);
    _path.shift(_positionAnimation.value);
    _path.close();
  }
}


///
/// RectangleContent
///
class RectangleDrawable extends _PolygonDrawable {

  final BaseKeyframeAnimation<dynamic, Offset> _positionAnimation;
  final BaseKeyframeAnimation<dynamic, Offset> _sizeAnimation;
  final BaseKeyframeAnimation<dynamic, double> _cornerRadiusAnimation;

  RectangleDrawable(String name, Repaint repaint, this._positionAnimation,
      this._sizeAnimation, this._cornerRadiusAnimation,) : super(name, repaint);

  @override
  void createPath() {
    final size = _sizeAnimation.value;
    final position = _positionAnimation.value;
    final halfWidth = size.dx / 2.0;
    final halfHeight = size.dy / 2.0;
    var radius = _cornerRadiusAnimation?.value ?? 0.0;
    radius = min(radius, min(halfWidth, halfHeight));

    _path.reset();
    _path.moveTo(position.dx + halfWidth, position.dy - halfHeight + radius);
    _path.lineTo(position.dx + halfWidth, position.dy + halfHeight - radius);

    if (radius > 0) {
      final rect = new Rect.fromLTRB(position.dx + halfWidth - 2 * radius,
          position.dy + halfHeight - 2 * radius,
          position.dx + halfWidth,
          position.dy + halfHeight);
      _path.arcTo(rect, 0.0, 90.0, false);
    }

    _path.lineTo(position.dx - halfWidth + radius, position.dy + halfHeight);

    if (radius > 0) {
      final rect = new Rect.fromLTRB(position.dx - halfWidth,
          position.dy + halfHeight - 2 * radius,
          position.dx - halfWidth + 2 * radius,
          position.dy + halfHeight);
      _path.arcTo(rect, 90.0, 90.0, false);
    }

    _path.lineTo(position.dx - halfWidth, position.dy - halfHeight + radius);

    if (radius > 0) {
      final rect = new Rect.fromLTRB(position.dx - halfWidth,
          position.dy - halfHeight,
          position.dx - halfWidth + 2 * radius,
          position.dy - halfHeight + 2 * radius);
      _path.arcTo(rect, 180.0, 90.0, false);
    }

    _path.lineTo(position.dx + halfWidth - radius, position.dy - halfHeight);

    if (radius > 0) {
      final rect = new Rect.fromLTRB(position.dx + halfWidth - 2 * radius,
          position.dy - halfHeight,
          position.dx + halfWidth,
          position.dy - halfHeight + 2 * radius);
      _path.arcTo(rect, 270.0, 90.0, false);
    }

    _path.close();
  }
}

///
/// ShapeDrawable
///
class ShapeDrawable extends _PolygonDrawable {

  final BaseKeyframeAnimation<dynamic, Path> _animation;

  ShapeDrawable(String name, Repaint repaint, this._animation) : super(name, repaint){
    addAnimation(_animation);
  }

  @override
  void createPath() {
    _path = _animation.value;
    _path.fillType = PathFillType.evenOdd;
  }

}
