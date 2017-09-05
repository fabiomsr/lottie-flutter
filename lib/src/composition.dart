import 'package:lottie_flutter/src/images.dart';
import 'package:lottie_flutter/src/layers.dart';
import 'package:lottie_flutter/src/parsers/composition_parsers.dart';
import 'package:flutter/painting.dart';
import 'dart:ui' as ui;

class LottieComposition {

  Map<String, List<Layer>> _preComps;
  Map<String, LottieImageAsset> _images;
  List<Layer> _layers;
  final Rect _bounds;
  final int _startFrame;
  final int _endFrame;
  final int _frameRate;
  final double _dpScale;

  int get duration {
    int frameDuration = _endFrame - _startFrame;
    return (frameDuration / _frameRate * 1000).toInt();
  }

  double get durationFrames => duration * _frameRate / 1000;

  bool get hasImages => _images.isNotEmpty;

  Map<String, List<Layer>> get preComps => _preComps;

  List<Layer> get layers => _layers;

  Rect get bounds => _bounds;

  LottieComposition.fromMap(dynamic map)
      : _bounds = parseBounds(map),
        _startFrame = parseStartFrame(map),
        _endFrame = parseEndFrame(map),
        _frameRate = parseFrameRate(map),
        _dpScale = ui.window.devicePixelRatio{
    _images = parseImages(map);
    _preComps = parsePreComps(
        map, _bounds.width, _bounds.height, _dpScale, durationFrames,
        _endFrame);
    _layers = parseLayers(
        map['layers'], _bounds.width, _bounds.height, _dpScale, durationFrames,
        _endFrame);
  }

  @override
  String toString() {
    return '{"_preComps": $_preComps, "_images": $_images, '
        '"_layers": $_layers, "_bounds": $_bounds, "_startFrame": $_startFrame, '
        '"_endFrame": $_endFrame, "_frameRate": $_frameRate, "_dpScale": $_dpScale}';
  }




}
