import 'dart:collection';
import 'package:Lotie_Flutter/core/Layer.dart';
import 'package:Lotie_Flutter/core/LottieImageAsset.dart';
import 'package:flutter/painting.dart';
import 'package:meta/meta.dart';

@immutable
class LottieComposition {

  final Map<String, List<Layer>> preComps;
  final Map<String, LottieImageAsset> _images;
  final Map<int, Layer> layerMap;
  final List<Layer> _layers;
  final Rect bounds;
  final int startFrame;
  final int endFrame;
  final int _frameRate;
  final double _dpScale;

  LottieComposition(this.bounds, this.startFrame, this.endFrame,
      this._frameRate, this._dpScale)
      : preComps = new HashMap<String, List<Layer>>(),
        _images = new HashMap<String, LottieImageAsset>(),
        layerMap = new HashMap<int, Layer>(),
        _layers = new List();


  int get duration {
    int frameDuration = endFrame - startFrame;
    return (frameDuration / _frameRate * 1000).toInt();
  }

  double get durationFrames => duration * _frameRate / 1000;

  bool get hasImages => _images.isNotEmpty;


}
