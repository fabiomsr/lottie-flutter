import 'dart:math';
import 'package:Lotie_Flutter/src/animatables.dart';
import 'package:Lotie_Flutter/src/animations.dart';
import 'package:Lotie_Flutter/src/drawing/drawing.dart';
import 'package:Lotie_Flutter/src/drawing/elements/paths.dart';
import 'package:Lotie_Flutter/src/elements/paths.dart';
import 'package:Lotie_Flutter/src/mathutils.dart';
import 'package:Lotie_Flutter/src/utils.dart';
import 'package:Lotie_Flutter/src/values.dart';
import 'package:flutter/painting.dart';
import 'package:vector_math/vector_math_64.dart';

class PathGroup {
  final List<PathContent> _paths = [];
  final TrimPathDrawable _trimPath;

  PathGroup(this._trimPath);
}

class StrokeDrawable extends AnimationDrawable {
  //TODO: PathMeasure https://github.com/flutter/flutter/issues/10428
  //final PathMeasure pm = new PathMeasure();
  final List<PathGroup> _pathGroups = [];
  final Paint _paint = new Paint();
  final Repaint _repaint;
  final BaseKeyframeAnimation<dynamic, int> _opacityAnimation;
  final BaseKeyframeAnimation<dynamic, double> _widthAnimation;
  final BaseKeyframeAnimation<dynamic, double> _dashPatternOffsetAnimation;
  final List<BaseKeyframeAnimation<dynamic, double>> _dashPatternAnimations;

  StrokeDrawable(
      String name,
      StrokeCap strokeCap,
      JoinType strokeJoin,
      List<AnimatableDoubleValue> dashPatternValues,
      this._repaint,
      this._opacityAnimation,
      this._widthAnimation,
      this._dashPatternOffsetAnimation)
      : _dashPatternAnimations = new List(dashPatternValues.length),
        super(name, _repaint) {
    _paint
      ..style = PaintingStyle.stroke
      ..strokeCap = strokeCap;
    //..strokeJoin = strokeJoin; //TODO

    addAnimation(_opacityAnimation);
    addAnimation(_widthAnimation);

    dashPatternValues
        .forEach((dashPattern) => addAnimation(dashPattern.createAnimation()));

    if (_dashPatternOffsetAnimation != null) {
      addAnimation(_dashPatternOffsetAnimation);
    }
  }

  @override
  void setContents(List<Content> contentsBefore, List<Content> contentsAfter) {
    TrimPathDrawable trimPathDrawableBefore;
    for (int i = contentsBefore.length - 1; i >= 0; i--) {
      Content content = contentsBefore[i];
      if (content is TrimPathDrawable &&
          content.type == ShapeTrimPathType.Individually) {
        trimPathDrawableBefore = content;
      }
    }

    if (trimPathDrawableBefore != null) {
      trimPathDrawableBefore.addListener(onValueChanged);
    }

    PathGroup currentPathGroup;

    for (int i = contentsAfter.length - 1; i >= 0; i--) {
      Content content = contentsAfter[i];
      if (content is TrimPathDrawable &&
          content.type == ShapeTrimPathType.Individually) {
        if (currentPathGroup != null) {
          _pathGroups.add(currentPathGroup);
        }

        currentPathGroup = new PathGroup(content);
        content.addListener(onValueChanged);
      } else if (content is PathContent) {
        currentPathGroup =
            currentPathGroup ?? new PathGroup(trimPathDrawableBefore);
        currentPathGroup._paths.add(content);
      }
    }

    if (currentPathGroup != null) {
      _pathGroups.add(currentPathGroup);
    }
  }

  void onValueChanged() {
    _repaint();
  }

  @override
  void draw(Canvas canvas, Size size, Matrix4 parentMatrix, int parentAlpha) {
    _paint
      ..strokeWidth = _widthAnimation.value * calculateScale(parentMatrix)
      ..color = _paint.color
          .withAlpha(calculateAlpha(parentAlpha, _opacityAnimation));

    if (_paint.strokeWidth <= 0) {
      // TODO: eview this
      // Android draws a hairline stroke for 0, After Effects doesn't and Flutter ??
      return;
    }

    _applyDashPatternIfNeeded(parentMatrix);

    for (var pathGroup in _pathGroups) {
      if (pathGroup._trimPath != null) {
        _applyTrimPath(canvas, pathGroup, parentMatrix);
      } else {
        Path path = new Path();
        for (int i = pathGroup._paths.length - 1; i >= 0; i--) {
          addPathToPath(path, pathGroup._paths[i].path, parentMatrix);
        }
        canvas.drawPath(path, _paint);
      }
    }
  }

  void _applyTrimPath(
      Canvas canvas, PathGroup pathGroup, Matrix4 parentMatrix) {
    if (pathGroup._trimPath == null) {
      return;
    }

    final path = new Path();
    for (int i = pathGroup._paths.length - 1; i >= 0; i--) {
      addPathToPath(path, pathGroup._paths[i].path, parentMatrix);
    }

    //TODO: PathMeasure https://github.com/flutter/flutter/issues/10428
    var totalLength;
//    pm.setPath(path, false);
//    double totalLength = pm.getLength();
//    while (pm.nextContour()) {
//      totalLength += pm.getLength();
//    }

    final trimPath = pathGroup._trimPath;
    final offsetLength = totalLength * trimPath.offset / 360.0;
    final startLength = totalLength * trimPath.start / 100.0 + offsetLength;
    final endLength = totalLength * trimPath.end / 100.0 + offsetLength;

    var currentLength = 0.0;
    for (int j = pathGroup._paths.length - 1; j >= 0; j--) {
      final trimPath = pathGroup._paths[j].path;
      trimPath.transform(parentMatrix.storage);

      //TODO: PathMeasure https://github.com/flutter/flutter/issues/10428
      var length = 0.0;
      //pm.setPath(trimPathPath, false);
      //double length = pm.getLength();

      if (endLength > totalLength &&
          endLength - totalLength < currentLength + length &&
          currentLength < endLength - totalLength) {
        _drawSegment(
            canvas, trimPath, length, startLength, endLength, totalLength);
        continue;
      }

      if (currentLength + length < startLength || currentLength > endLength) {
        currentLength += length;
        continue;
      }

      if (currentLength + length <= endLength && startLength < currentLength) {
        canvas.drawPath(trimPath, _paint);
        currentLength += length;
        continue;
      }

      var start = startLength < currentLength
          ? 0.0
          : (startLength - currentLength) / length;
      var end = endLength > currentLength + length
          ? 1.0
          : (endLength - currentLength) / length;

      final path = applyTrimPathIfNeeded(trimPath, start, end, 0.0);
      canvas.drawPath(path, _paint);
      currentLength += length;
    }
  }

  /// Draw the segment when the end is greater than the length which wraps
  /// around to the beginning.
  void _drawSegment(Canvas canvas, Path path, double length, double startLength,
      double endLength, double totalLength) {
    var start =
        startLength > totalLength ? (startLength - totalLength) / length : 0.0;
    var end = min((endLength - totalLength) / length, 1);
    Path trimPath = applyTrimPathIfNeeded(path, start, end, 0.0);
    canvas.drawPath(trimPath, _paint);
  }

  @override
  Rect getBounds(Matrix4 parentMatrix) {
    final path = new Path();
    for (var pathGroup in _pathGroups) {
      for (var pathContent in pathGroup._paths) {
        addPathToPath(path, pathContent.path, parentMatrix);
      }
    }

    Rect outBounds = new Rect.fromLTRB(0.0, 0.0, 0.0, 0.0);
    //TODO: computeBounds method is not expose
    //path.computeBounds(outBounds, false);

    final width = _widthAnimation.value;
    return new Rect.fromLTRB(
        outBounds.left - width / 2.0 - 1,
        outBounds.top - width / 2.0 - 1,
        outBounds.right + width / 2.0 + 1,
        outBounds.bottom + width / 2.0 + 1);
  }

  void _applyDashPatternIfNeeded(Matrix4 parentMatrix) {
    if (_dashPatternAnimations.isEmpty) {
      return;
    }

    //TODO: DashPathEffect
    /*
    double scale = calculateScale(parentMatrix);
    for (int i = 0; i < _dashPatternAnimations.length; i++) {
      dashPatternValues[i] = dashPatternAnimations.get(i).getValue();
      // If the value of the dash pattern or gap is too small, the number of individual sections
      // approaches infinity as the value approaches 0.
      // To mitigate this, we essentially put a minimum value on the dash pattern size of 1px
      // and a minimum gap size of 0.01.
      if (i % 2 == 0) {
        if (dashPatternValues[i] < 1f) {
          dashPatternValues[i] = 1f;
        }
      } else {
        if (dashPatternValues[i] < 0.1f) {
          dashPatternValues[i] = 0.1f;
        }
      }
      dashPatternValues[i] *= scale;
    }

    final offset = _dashPatternOffsetAnimation == null ? 0.0 : _dashPatternOffsetAnimation.value;
    _paint.pathEffect = new DashPathEffect(dashPatternValues, offset);
    */
  }
}

class ShapeStrokeDrawable extends StrokeDrawable {
  final KeyframeAnimation<Color> _colorAnimation;

  ShapeStrokeDrawable(
      String name,
      StrokeCap strokeCap,
      JoinType strokeJoin,
      List<AnimatableDoubleValue> dashPatternValues,
      Repaint repaint,
      BaseKeyframeAnimation<dynamic, int> opacityAnimation,
      BaseKeyframeAnimation<dynamic, double> widthAnimation,
      BaseKeyframeAnimation<dynamic, double> dashPatternOffsetAnimation,
      this._colorAnimation)
      : super(name, strokeCap, strokeJoin, dashPatternValues, repaint,
            opacityAnimation, widthAnimation, dashPatternOffsetAnimation) {
    addAnimation(_colorAnimation);
  }

  @override
  void addColorFilter(
      String layerName, String contentName, ColorFilter colorFilter) {
    _paint.colorFilter = colorFilter;
  }

  @override
  void draw(Canvas canvas, Size size, Matrix4 parentMatrix, int parentAlpha) {
    _paint.color = _colorAnimation.value;
    super.draw(canvas, size, parentMatrix, parentAlpha);
  }
}

class GradientStrokeDrawable extends StrokeDrawable {
  final GradientType _type;
  final KeyframeAnimation<GradientColor> _colorAnimation;
  final KeyframeAnimation<Offset> _startPointAnimation;
  final KeyframeAnimation<Offset> _endPointAnimation;

  GradientStrokeDrawable(
      String name,
      StrokeCap strokeCap,
      JoinType strokeJoin,
      List<AnimatableDoubleValue> dashPatternValues,
      Repaint repaint,
      BaseKeyframeAnimation<dynamic, int> opacityAnimation,
      BaseKeyframeAnimation<dynamic, double> widthAnimation,
      BaseKeyframeAnimation<dynamic, double> dashPatternOffsetAnimation,
      this._type,
      this._colorAnimation,
      this._startPointAnimation,
      this._endPointAnimation)
      : super(name, strokeCap, strokeJoin, dashPatternValues, repaint,
            opacityAnimation, widthAnimation, dashPatternOffsetAnimation) {
    addAnimation(_colorAnimation);
    addAnimation(_widthAnimation);
    addAnimation(_dashPatternOffsetAnimation);
  }

  @override
  void draw(Canvas canvas, Size size, Matrix4 parentMatrix, int parentAlpha) {
    final bounds = getBounds(parentMatrix);
    _paint.shader =  createGradientShader(_colorAnimation.value,
        _type , _startPointAnimation.value, _endPointAnimation.value, bounds);

    super.draw(canvas, size, parentMatrix, parentAlpha);
  }
}
