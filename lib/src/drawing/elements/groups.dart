import 'dart:math';
import 'dart:ui';

import 'package:Lotie_Flutter/src/drawing/drawing.dart';
import 'package:Lotie_Flutter/src/drawing/elements/paths.dart';
import 'package:Lotie_Flutter/src/elements/transforms.dart';
import 'package:Lotie_Flutter/src/utils.dart';

import 'package:vector_math/vector_math_64.dart';

class DrawableGroup extends AnimationDrawable implements PathContent {
  final List<AnimationDrawable> _contents;
  List<PathContent> _pathContents = [];
  final TransformKeyframeAnimation _transformAnimation;

  @override
  Path get path {
    Path path = new Path();
    for (int i = _contents.length - 1; i >= 0; i--) {
      Content content = _contents[i];
      if (content is PathContent) {
        addPathToPath(path, content.path, transformation);
      }
    }

    return path;
  }

  List<PathContent> get paths {
    if (_pathContents.isNotEmpty) {
      return _pathContents;
    }

    for(var content in _contents) {
      if(content is PathContent) {
        _pathContents.add(content as PathContent);
      }
    }

    return _pathContents;
  }

  Matrix4 get transformation {
    return _transformAnimation?.matrix ?? new Matrix4.identity();
  }

  DrawableGroup(
      String name, Repaint repaint, this._contents, this._transformAnimation)
      : super(name, repaint) {
    List<Content> contentsToRemove = [];
    MergePathsDrawable currentMergePathsContent;
    for (int i = _contents.length - 1; i >= 0; i--) {
      Content content = _contents[i];
      if (content is MergePathsDrawable) {
        currentMergePathsContent = content;
      }
      if (currentMergePathsContent != null &&
          content != currentMergePathsContent) {
        currentMergePathsContent.addContentIfNeeded(content);
        contentsToRemove.add(content);
      }
    }

    _contents.removeWhere((content) => contentsToRemove.contains(content));
  }

  @override
  void setContents(List<Content> contentsBefore, List<Content> contentsAfter) {
    // Do nothing with contents after.
    final myContentsBefore = [];
    contentsBefore.forEach((content) => myContentsBefore.add(content));

    for (int i = _contents.length - 1; i >= 0; i--) {
      Content content = _contents[i];
      content.setContents(myContentsBefore, _contents.sublist(0, i));
      myContentsBefore.add(content);
    }
  }

  @override
  void addColorFilter(
      String layerName, String contentName, ColorFilter colorFilter) {
    for (var content in _contents) {
      if (contentName == null || contentName == content.name) {
        content.addColorFilter(layerName, null, colorFilter);
      } else {
        content.addColorFilter(layerName, contentName, colorFilter);
      }
    }
  }

  @override
  void draw(Canvas canvas, Size size, Matrix4 parentMatrix, int parentAlpha) {
    Matrix4 matrix = new Matrix4.fromFloat64List(parentMatrix.storage);

    int alpha = parentAlpha;
    if(_transformAnimation != null) {
      matrix.multiply(_transformAnimation.matrix);
      int transformOpacity = _transformAnimation.opacity.value;
      alpha = ((transformOpacity / 100.0 * parentAlpha / 255.0) * 255.0).toInt();
    }

    for (int i = _contents.length - 1; i >= 0; i--) {
      _contents[i].draw(canvas, size, matrix, alpha);
    }
  }

  @override
  Rect getBounds(Matrix4 parentMatrix) {
    Matrix4 matrix = new Matrix4.identity();

    if(_transformAnimation != null){
      matrix.multiply(_transformAnimation.matrix);
    }

    Rect bounds = new Rect.fromLTRB(0.0, 0.0, 0.0, 0.0);
    for (int i = _contents.length - 1; i >= 0; i--) {
      AnimationDrawable content = _contents[i];
        final rect = content.getBounds(matrix);
        if (bounds.isEmpty) {
          bounds = rect;
        } else {
          bounds = new Rect.fromLTRB(
              min(bounds.left, rect.left),
              min(bounds.top, rect.top),
              max(bounds.right, rect.right),
              max(bounds.bottom, rect.bottom)
          );
        }
    }

    return bounds;
  }
}
