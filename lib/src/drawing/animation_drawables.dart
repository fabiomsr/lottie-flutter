import 'dart:math';
import 'dart:ui';
import 'package:Lotie_Flutter/src/animations.dart';
import 'package:Lotie_Flutter/src/drawing/drawing.dart';
import 'package:Lotie_Flutter/src/elements/shapes.dart';
import 'package:Lotie_Flutter/src/utils.dart';
import 'package:Lotie_Flutter/src/values.dart';
import 'package:vector_math/vector_math_64.dart';

class ContentGroup implements Drawable {
  ContentGroup(String name, List<Shape> shapes);

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

  // TODO: implement name
  @override
  String get name => null;
}


abstract class _PolygonDrawable extends AnimationDrawable
    implements PathDrawable {

  bool _isPathValid = false;
  TrimPathDrawable _trimPathDrawable;
  final Path _path = new Path();

  _PolygonDrawable(String name, Repaint repaint) : super(name, repaint);

  Path get path {
    if (_isPathValid) {
      return _path;
    }

    _path.reset();
    createPath();
    _path.close();

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
  }
}


///
/// TrimPathDrawable
///
class TrimPathDrawable extends AnimationDrawable {

  final ShapeTrimPathType _type;
  final List<OnValueChanged> _listeners = [];
  final BaseKeyframeAnimation<dynamic, double> _startAnimation;
  final BaseKeyframeAnimation<dynamic, double> _endAnimation;
  final BaseKeyframeAnimation<dynamic, double> _offsetAnimation;

  ShapeTrimPathType get type => _type;

  double get start => _startAnimation.value;

  double get end => _endAnimation.value;

  double get offset => _offsetAnimation.value;

  TrimPathDrawable(String name, Repaint repaint, this._type,
      this._startAnimation,
      this._endAnimation, this._offsetAnimation)
      : super(name, repaint) {
    addAnimation(_startAnimation);
    addAnimation(_endAnimation);
    addAnimation(_offsetAnimation);
  }

  @override
  void onValueChanged() {
    _listeners.forEach((listener) => listener());
  }

  void addListener(OnValueChanged listener) {
    _listeners.add(listener);
  }
}

