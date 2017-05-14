import 'dart:math';
import 'package:Lotie_Flutter/src/animations.dart';
import 'package:Lotie_Flutter/src/drawing/drawing.dart';
import 'package:Lotie_Flutter/src/layers.dart';
import 'package:Lotie_Flutter/src/painting.dart';
import 'package:Lotie_Flutter/src/values.dart';
import 'package:Lotie_Flutter/src/transform.dart';
import 'package:flutter/painting.dart';
import 'package:vector_math/vector_math_64.dart';


abstract class BaseLayer implements DrawingContent {

  bool _visibility = true;
  BaseLayer _parent;
  List<BaseLayer> _parents;
  BaseLayer _matteLayer;
  Path _path = new Path();

  final Layer _layerModel;
  final Paint _contentPaint = new Paint();
  final Paint _maskPaint = new Paint();
  final Paint _mattePaint = new Paint();
  final Paint _clearPaint = new Paint();
  final Matrix4 _matrix = new Matrix4.identity();
  final Matrix4 _bounds = new Matrix4.identity();
  final MaskKeyframeAnimation _mask;
  final TransformKeyframeAnimation _transform;
  final List<BaseKeyframeAnimation<dynamic, dynamic>> _animations = new List();


  Layer get layerModel => _layerModel;

  bool get hasMatte => _matteLayer != null;
  bool get hasMasks => _mask.animations.isNotEmpty;

  set matteLayer(BaseLayer layer) => _matteLayer = layer;

  set parent(BaseLayer layer) => _parent = layer;

  set visibility(bool value) {
    if (value != _visibility) {
      _visibility = value;
      invalidateSelf();
    }
  }

  /// Set animation progress, from 0 to 1
  set progress(double progress) {
    _matteLayer?.progress = progress;
    _animations.forEach((animation) => animation.progress = progress);
  }

  BaseLayer(this._layerModel)
      : _transform = new TransformKeyframeAnimation(_layerModel.transform),
        _mask = new MaskKeyframeAnimation(
            _layerModel.masks == null ? const [] : _layerModel.masks) {
    _clearPaint.blendMode = BlendMode.clear;
    _maskPaint.blendMode = BlendMode.dstIn;
    _mattePaint.blendMode =
    _layerModel.matteType == MatteType.Invert ? BlendMode.dstOut : BlendMode
        .dstIn;

    _transform.addListener(onAnimationChanged);
    addAnimationsToLayer();

    for (var animation in _mask.animations) {
      addAnimation(animation);
      animation.addListener(onAnimationChanged);
    }

    setupInOutAnimations();
  }

  void addAnimation(BaseKeyframeAnimation<dynamic, dynamic> newAnimation) {
    if (newAnimation is! StaticKeyframeAnimation) {
      _animations.add(newAnimation);
    }
  }

  void addAnimationsToLayer() {
    addAnimation(_transform.anchorpoint);
    addAnimation(_transform.position);
    addAnimation(_transform.rotation);
    addAnimation(_transform.scale);
    addAnimation(_transform.opacity);
  }

  void onAnimationChanged() {
    invalidateSelf();
  }

  void setupInOutAnimations() {
    if (_layerModel.inOutKeyframes.isEmpty) {
      visibility = true;
      return;
    }

    final DoubleKeyframeAnimation inOutAnimation = new DoubleKeyframeAnimation(
        _layerModel.inOutKeyframes);

    inOutAnimation.isDiscrete = true;
    inOutAnimation.addListener(() => _visibility = inOutAnimation.value == 1.0);
    _visibility = inOutAnimation.value == 1.0;
    addAnimation(inOutAnimation);
  }

  void invalidateSelf() {
    //TODO: invalidate layer
  }

  @override
  Rect getBounds(Matrix4 parentMatrix) {
    _bounds.setFrom(parentMatrix);
    _bounds.multiply(_transform.matrix);
    return calculateBounds(parentMatrix);
  }

  @override
  void draw(Canvas canvas, Size size, Matrix4 parentMatrix, int parentAlpha) {
    if (!_visibility) {
      return;
    }

    buildParentLayerListIfNeeded();

    _matrix.setFrom(parentMatrix);

    for (int i = _parents.length - 1; i >= 0; i--) {
      _matrix.multiply(_parents[i]._transform.matrix);
    }

    int alpha = ((parentAlpha / 255.0 * _transform.opacity.value / 100.0) *
        255.0).toInt();

    if(!hasMatte && !hasMasks) {
      _matrix.multiply(_transform.matrix);
      drawLayer(canvas, size, _matrix, alpha);
      return;
    }

    Rect rect = getBounds(_matrix);
    rect = intersectBoundsWithMatte(rect, _matrix);

    _matrix.multiply(_transform.matrix);
    intersectBoundsWithMask(rect, _matrix);
    
    Rect canvasBounds = new Rect.fromLTRB(0.0, 0.0, size.width, size.height);
    canvas.saveLayer(canvasBounds, _contentPaint);
    clearCanvas(canvas, canvasBounds);
    drawLayer(canvas, size, _matrix, alpha);

    if(hasMasks) {
      applyMasks(canvas,canvasBounds, _matrix);
    }

    if(hasMatte) {
      canvas.saveLayer(canvasBounds, _mattePaint);
      clearCanvas(canvas, canvasBounds);
      _matteLayer.draw(canvas, size, parentMatrix, parentAlpha);
      canvas.restore();
    }

    canvas.restore();
  }

  void clearCanvas(Canvas canvas, Rect bounds) {
    // TODO: Does this happen in Flutter too?
    // IF we don't pad the clear draw, some phones leave a 1px border of the
    // graphics buffer.
    canvas.drawRect(new Rect.fromLTRB(bounds.left - 1, bounds.top - 1,
        bounds.right - 1, bounds.bottom - 1), _clearPaint);
  }

  void buildParentLayerListIfNeeded() {
    if (_parents != null) {
      return;
    }

    if (_parent == null) {
      _parents = const [];
    }

    _parents = new List();
    BaseLayer layer = _parent;
    while (layer != null) {
      _parents.add(layer);
      layer = layer._parent;
    }
  }

  Rect intersectBoundsWithMatte(Rect rect, Matrix4 matrix) {
    if(!hasMatte || layerModel.matteType == MatteType.Invert) {
      // We can't trim the bounds if the mask is inverted since it extends all
      // the way to the composition bounds
      return rect;
    }

    Rect bounds = _matteLayer.getBounds(matrix);
    return _max(rect, bounds);
  }

  void intersectBoundsWithMask(Rect rect, Matrix4 matrix) {
    if(!hasMasks) {
      return;
    }

    final int length = _mask.masks.length;
    Rect maskBoundRect = new Rect.fromLTRB(0.0, 0.0, 0.0, 0.0);

    for(int i = 0; i < length; i++) {
      var mask = _mask.masks[i];
      var animation = _mask.animations[i];

      _path = animation.value;
      _path = _path.transform(_matrix.storage);

      switch(mask.mode) {
        case MaskMode.Subtract:
          // If there is a subtract mask, the mask could potentially be the size
          // of the entire canvas so we can't use the mask bounds
          return;
        case MaskMode.Add:
        default:
          Rect tempMaskBoundRect = new Rect.fromLTRB(0.0, 0.0, 0.0, 0.0);
          // TODO: Open issue about Path::computeBounds
          //_path.computeBounds(tempMaskBoundRect, false);
          print("MaskMode.Add|Intersect|Unknown are not supported for now");

          // As we iterate through the masks, we want to calculate the union region
          // of the masks. We initialize the rect with the first mask.
          maskBoundRect = i == 0 ? maskBoundRect : _max(maskBoundRect, tempMaskBoundRect);
      }
    }

  }


  void applyMasks(Canvas canvas,Rect bounds, Matrix4 matrix) {
    canvas.saveLayer(bounds, _maskPaint);
    clearCanvas(canvas, bounds);

    final int length = _mask.masks.length;
    for(int i = 0; i < length; i++) {
      var mask = _mask.masks[i];
      var animation = _mask.animations[i];

      _path = animation.value;
      _path = _path.transform(_matrix.storage);

      switch(mask.mode) {
        case MaskMode.Subtract:
          // TODO: Open issue about PathFillType.inverseWinding
          //_path.fillType = PathFillType.inverseWinding;
          print("MaskMode.Subtract is not supported for now");
          break;
        case MaskMode.Add:
        default:
          _path.fillType = PathFillType.nonZero;
          break;
      }

      canvas.drawPath(_path, _contentPaint);
    }

    canvas.restore();
  }


  Rect _max(Rect first, Rect second)
    => new Rect.fromLTRB(max(first.left, second.left),
        max(first.top, second.top),
        max(first.right, second.right),
        max(first.bottom, second.bottom));

  Rect calculateBounds(Matrix4 parentMatrix);
  void drawLayer(Canvas canvas, Size size, Matrix4 parentMatrix, int parentAlpha);
  
}