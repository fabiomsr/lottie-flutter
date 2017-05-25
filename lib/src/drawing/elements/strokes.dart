import 'package:Lotie_Flutter/src/animatables.dart';
import 'package:Lotie_Flutter/src/animations.dart';
import 'package:Lotie_Flutter/src/drawing/drawing.dart';
import 'package:Lotie_Flutter/src/drawing/elements/paths.dart';
import 'package:Lotie_Flutter/src/elements/paths.dart';
import 'package:Lotie_Flutter/src/values.dart';
import 'package:flutter/painting.dart';


class PathGroup {
  final List<PathContent> _paths = [];
  final TrimPathDrawable _trimPath;

  PathGroup(this._trimPath);
}

class StrokeDrawable extends AnimationDrawable {

  //TODO: PathMeasure
  //final PathMeasure pm = new PathMeasure();
  final List<PathGroup> _pathGroups = [];
  final Paint _paint = new Paint();
  final Repaint _repaint;
  final BaseKeyframeAnimation<dynamic, int> _opacityAnimation;
  final BaseKeyframeAnimation<dynamic, double> _widthAnimation;
  final BaseKeyframeAnimation<dynamic, double> _dashPatternOffsetAnimation;
  final List<BaseKeyframeAnimation<dynamic, double>> _dashPatternAnimations;


  StrokeDrawable(String name, StrokeCap strokeCap,
      JoinType strokeJoin, List<AnimatableDoubleValue> dashPatternValues,
      this._repaint, this._opacityAnimation,
      this._widthAnimation, this._dashPatternOffsetAnimation)
      :
        _dashPatternAnimations = new List(dashPatternValues.length),
        super(name, _repaint) {
    _paint
      ..style = PaintingStyle.stroke
      ..strokeCap = strokeCap;
    //..strokeJoin = strokeJoin; //TODO

    addAnimation(_opacityAnimation);
    addAnimation(_widthAnimation);

    dashPatternValues.forEach((dashPattern) =>
        addAnimation(dashPattern.createAnimation()));

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
        currentPathGroup = currentPathGroup ?? new PathGroup(trimPathDrawableBefore);
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
}

