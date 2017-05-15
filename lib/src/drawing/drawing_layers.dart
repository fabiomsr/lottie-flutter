import 'dart:math';
import 'dart:ui';
import 'package:Lotie_Flutter/core/LottieComposition.dart';
import 'package:Lotie_Flutter/src/animations.dart';
import 'package:Lotie_Flutter/src/drawing/drawing.dart';
import 'package:Lotie_Flutter/src/drawing/drawing_content.dart';
import 'package:Lotie_Flutter/src/layers.dart';
import 'package:Lotie_Flutter/src/painting.dart';
import 'package:Lotie_Flutter/src/transform.dart';
import 'package:flutter/painting.dart';

import 'package:vector_math/vector_math_64.dart';


BaseLayer layerForModel(Layer layer, LottieComposition composition,
    double scale) {
  switch (layer.type) {
    case LayerType.Shape:
      return new ShapeLayer(layer);
    case LayerType.PreComp:
      return new CompositionLayer(composition, layer, scale);
    case LayerType.Solid:
      return new SolidLayer(layer);
    case LayerType.Image:
      return new ImageLayer(layer, scale);
    case LayerType.Null:
      return new NullLayer(layer);
    case LayerType.Text:
    case LayerType.Unknown:
    default: // Do nothing
      print("Unknown layer type ${layer.type}");
      return null;
  }
}

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

  bool get hasMatteOnThisLayer => _matteLayer != null;

  bool get hasMasksOnThisLayer => _mask.animations.isNotEmpty;

  @override
  String get name => _layerModel.name;

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
  void setContents(List<Content> contentsBefore, List<Content> contentsAfter) {
    // Do nothing
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

    int alpha = calculateAlpha(parentAlpha);

    if (!hasMatteOnThisLayer && !hasMasksOnThisLayer) {
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

    if (hasMasksOnThisLayer) {
      applyMasks(canvas, canvasBounds, _matrix);
    }

    if (hasMatteOnThisLayer) {
      canvas.saveLayer(canvasBounds, _mattePaint);
      clearCanvas(canvas, canvasBounds);
      _matteLayer.draw(canvas, size, parentMatrix, parentAlpha);
      canvas.restore();
    }

    canvas.restore();
  }

  int calculateAlpha(int from) =>
      ((from / 255.0 * _transform.opacity.value / 100.0) * 255.0).toInt();


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
    if (!hasMatteOnThisLayer || layerModel.matteType == MatteType.Invert) {
      // We can't trim the bounds if the mask is inverted since it extends all
      // the way to the composition bounds
      return rect;
    }

    Rect bounds = _matteLayer.getBounds(matrix);
    return _maxLeftTopMinRightBottom(rect, bounds);
  }

  void intersectBoundsWithMask(Rect rect, Matrix4 matrix) {
    if (!hasMasksOnThisLayer) {
      return;
    }

    final int length = _mask.masks.length;
    Rect maskBoundRect = new Rect.fromLTRB(0.0, 0.0, 0.0, 0.0);

    for (int i = 0; i < length; i++) {
      var mask = _mask.masks[i];
      var animation = _mask.animations[i];

      _path = animation.value;
      _path = _path.transform(_matrix.storage);

      switch (mask.mode) {
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
          maskBoundRect = i == 0 ? maskBoundRect : _minTopLeftMaxRightBottom(
              maskBoundRect, tempMaskBoundRect);
      }
    }
  }

  void applyMasks(Canvas canvas, Rect bounds, Matrix4 matrix) {
    canvas.saveLayer(bounds, _maskPaint);
    clearCanvas(canvas, bounds);

    final int length = _mask.masks.length;
    for (int i = 0; i < length; i++) {
      var mask = _mask.masks[i];
      var animation = _mask.animations[i];

      _path = animation.value;
      _path = _path.transform(_matrix.storage);

      switch (mask.mode) {
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

  Rect _maxLeftTopMinRightBottom(Rect first, Rect second) =>
      new Rect.fromLTRB(max(first.left, second.left),
          max(first.top, second.top),
          min(first.right, second.right),
          min(first.bottom, second.bottom));

  Rect _minTopLeftMaxRightBottom(Rect first, Rect second) =>
      new Rect.fromLTRB(min(first.left, second.left),
          min(first.top, second.top),
          max(first.right, second.right),
          max(first.bottom, second.bottom));

  Rect calculateBounds(Matrix4 parentMatrix);

  void drawLayer(Canvas canvas, Size size, Matrix4 parentMatrix,
      int parentAlpha);

}


class SolidLayer extends BaseLayer {

  final Paint _paint = new Paint();

  SolidLayer(Layer layerModel) : super(layerModel) {
    _paint.color = layerModel.solidColor;
    _paint.style = PaintingStyle.fill;
  }

  @override
  void drawLayer(Canvas canvas, Size size, Matrix4 parentMatrix,
      int parentAlpha) {
    if (layerModel.solidColor.alpha == 0) {
      return;
    }

    int alpha = calculateAlpha(layerModel.solidColor.alpha);
    _paint.color = _paint.color.withAlpha(alpha);

    if (alpha == 0) {
      Rect transformRect = calculateTransform(parentMatrix);
      canvas.drawRect(transformRect, _paint);
    }
  }

  Rect calculateTransform(Matrix4 parentMatrix) {
    Rect canvasBounds = new Rect.fromLTRB(
        0.0, 0.0, _layerModel.solidWidth.toDouble(),
        _layerModel.solidHeight.toDouble());
    Rect transformRect = MatrixUtils.transformRect(parentMatrix, canvasBounds);
    return transformRect;
  }

  @override
  Rect calculateBounds(Matrix4 parentMatrix) {
    return calculateBounds(parentMatrix);
  }

  @override
  void addColorFilter(String layerName, String contentName,
      ColorFilter colorFilter) {
    _paint.colorFilter = colorFilter;
  }
}


class ShapeLayer extends BaseLayer {

  final ContentGroup _contentGroup;

  ShapeLayer(Layer layerModel)
      : _contentGroup = new ContentGroup(layerModel.name, layerModel.shapes),
        super(layerModel) {
    _contentGroup.setContents(const [], const []);
  }

  @override
  void drawLayer(Canvas canvas, Size size, Matrix4 parentMatrix,
      int parentAlpha) {
    _contentGroup.draw(canvas, size, parentMatrix, parentAlpha);
  }

  @override
  Rect calculateBounds(Matrix4 parentMatrix) {
    return _contentGroup.getBounds(parentMatrix);
  }

  @override
  void addColorFilter(String layerName, String contentName,
      ColorFilter colorFilter) {
    _contentGroup.addColorFilter(layerName, contentName, colorFilter);
  }
}


class ImageLayer extends BaseLayer {

  final Paint _paint = new Paint();
  final double _density;

  ImageLayer(Layer layerModel, this._density) : super(layerModel) {
    _paint
      ..isAntiAlias = true
      ..filterQuality = FilterQuality.low; // bilinear interpolation
  }

  @override
  void drawLayer(Canvas canvas, Size size, Matrix4 parentMatrix,
      int parentAlpha) {
    //TODO: fetch image from refId
    Image image = _getImage();

    if (image == null) {
      return;
    }

    _paint.color = _paint.color.withAlpha(parentAlpha);
    canvas.save();
    canvas.transform(parentMatrix.storage);
    Rect imageBounds = new Rect.fromLTRB(
        0.0, 0.0, image.width.toDouble(), image.height.toDouble());
    Rect destiny = new Rect.fromLTRB(
        0.0, 0.0, image.width * _density, image.height * _density);
    canvas.drawImageRect(image, imageBounds, destiny, _paint);
    canvas.restore();
  }

  @override
  Rect calculateBounds(Matrix4 parentMatrix) {
    Image image = _getImage();
    if (image != null) {
      Rect bounds = new Rect.fromLTRB(
          0.0, 0.0, image.width.toDouble(), image.height.toDouble());
      return MatrixUtils.transformRect(parentMatrix, bounds);
    }

    return new Rect.fromLTRB(0.0, 0.0, 0.0, 0.0);
  }

  @override
  void addColorFilter(String layerName, String contentName,
      ColorFilter colorFilter) {
    _paint.colorFilter = colorFilter;
  }

  Image _getImage() {
    //TODO: fetch image from refId
    return null;
  }


}

class NullLayer extends BaseLayer {
  NullLayer(Layer layerModel) : super(layerModel);

  @override
  void addColorFilter(String layerName, String contentName,
      ColorFilter colorFilter) {
    // Do nothing
  }

  @override
  Rect calculateBounds(Matrix4 parentMatrix) {
    return new Rect.fromLTRB(0.0, 0.0, 0.0, 0.0);
  }

  @override
  void drawLayer(Canvas canvas, Size size, Matrix4 parentMatrix,
      int parentAlpha) {
    // Do nothing
  }
}

class CompositionLayer extends BaseLayer {

  final List<BaseLayer> _layers = new List<BaseLayer>();
  bool _hasMatte;
  bool _hasMasks;

  CompositionLayer(LottieComposition composition, Layer layerModel,
      double scale)
      : super(layerModel) {
    List<Layer> layerModels = composition.preComps[layerModel.refId];
    Map<int, BaseLayer> layers = new Map<int, BaseLayer>();

    for (int i = layerModels.length - 1; i >= 0; i--) {
      Layer currentLayerModel = layerModels[i];
      BaseLayer layer = layerForModel(currentLayerModel, composition, scale);

      if (layer == null) {
        continue;
      }

      layers[layer.layerModel.id] = layer;

      if (_matteLayer == null) {
        _matteLayer._matteLayer = layer;
        _matteLayer = null;
      } else {
        _layers.insert(0, layer);
        switch (currentLayerModel.matteType) {
          case MatteType.Add:
          case MatteType.Invert:
            _matteLayer = layer;
            break;
          default:
            break;
        }
      }
    }

    layers.forEach((key, currentLayer) {
      BaseLayer parent = layers[currentLayer.layerModel.parentId];
      if (parent != null) {
        currentLayer.parent = parent;
      }
    });
  }


  @override
  void drawLayer(Canvas canvas, Size size, Matrix4 parentMatrix,
      int parentAlpha) {
    // TODO: Open issue about SkCanvas::getClipBounds
    // Rect canvasClipBounds = canvas.getClipBounds();

    Rect newClipRect = new Rect.fromLTRB(
        0.0, 0.0, layerModel.preCompWidth, layerModel.preCompHeight);
    Rect transformedRect = MatrixUtils.transformRect(parentMatrix, newClipRect);

    for (int i = _layers.length - 1; i >= 0 ; i--) {
      if(!newClipRect.isEmpty) {
        canvas.clipRect(newClipRect);
      }

      _layers[i].draw(canvas, size, parentMatrix, parentAlpha);
    }

    //if (!originalClipRect.isEmpty()) {
    // TODO: Open issue about Replace option
      //canvas.clipRect(canvasClipBounds, Region.Op.REPLACE);
    //}
  }

  @override
  Rect calculateBounds(Matrix4 parentMatrix) {
    Rect layerBounds = new Rect.fromLTRB(0.0, 0.0, 0.0, 0.0);
    for (int i = _layers.length - 1; i >= 0; i--) {
      BaseLayer content = _layers[i];
      Rect contentBounds = content.getBounds(parentMatrix);

      layerBounds = layerBounds.isEmpty ? contentBounds
          : _minTopLeftMaxRightBottom(layerBounds, contentBounds);
    }

    return layerBounds;
  }


  @override
  void addColorFilter(String layerName, String contentName,
      ColorFilter colorFilter) {
    for(var layer in _layers) {
      final String name = layer.layerModel.name;
      if(layerName == null) {
        layer.addColorFilter(null, null, colorFilter);
      } else {
        layer.addColorFilter(layerName, contentName, colorFilter);
      }
    }
  }

  @override
  set progress(double progress) {
    super.progress = progress;
    double newProgress = progress - _layerModel.startProgress;
    for (int i = _layers.length - 1; i >= 0; i--) {
      _layers[i].progress = progress;
    }
  }

  bool get hasMasks {
    if(_hasMasks == null) {
      for (int i = _layers.length - 1; i >= 0; i--) {
        BaseLayer layer = _layers[i];
        if(layer is ShapeLayer && layer.hasMasksOnThisLayer) {
          _hasMasks = true;
          return true;
        }
      }
      _hasMasks = false;
    }

    return _hasMasks;
  }

  bool get hasMatte {
    if (_hasMatte == null) {
      if (hasMatteOnThisLayer) {
        _hasMatte = true;
        return true;
      }

      for (int i = _layers.length - 1; i >= 0; i--) {
        BaseLayer layer = _layers[i];
        if(layer.hasMatteOnThisLayer){
          _hasMatte = true;
          return true;
        }
      }

      _hasMatte = false;
    }

    return _hasMatte;
  }
}

