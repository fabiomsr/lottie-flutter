import 'dart:ui' as ui;

import 'package:Lotie_Flutter/src/images.dart';
import 'package:Lotie_Flutter/src/layers.dart';
import 'package:flutter/painting.dart' show Rect;

int parseStartFrame(dynamic map) => map['ip'] ?? 0.0;

int parseEndFrame(dynamic map) => map['op'] ?? 0.0;

int parseFrameRate(dynamic map) => map['fr'] ?? 0.0;

Rect parseBounds(dynamic map) {
  double scale = ui.window.devicePixelRatio;
  int width = map['w'];
  int height = map['h'];

  if (width != null && height != null) {
    double scaledWidth = width * scale;
    double scaledHeight = height * scale;
    return new Rect.fromLTRB(0.0, 0.0, scaledWidth, scaledHeight);
  }

  return new Rect.fromLTRB(0.0, 0.0, 0.0, 0.0);
}

Map<String, LottieImageAsset> parseImages(dynamic map) {
  List rawAssets = map["assets"];

  if (rawAssets == null) {
    return const {};
  }

  return rawAssets.where((rawAsset) => rawAsset.containsKey('p'))
      .map((rawAsset) => new LottieImageAsset.fromMap(rawAsset))
      .fold({}, (assets, image) {
    assets[image.id] = image;
    return assets;
  });
}


Map<String, List<Layer>> parsePreComps(dynamic map, double width, double height,
    double scale, double durationFrames, int endFrame) {
  List rawAssets = map["assets"];

  if (rawAssets == null) {
    return const {};
  }

  return rawAssets.where((rawAsset) => rawAsset["layers"] != null)
      .fold({}, (preComps, rawAsset) {
    preComps[rawAsset['id']] = parseLayers(
        rawAsset["layers"], width, height, scale, durationFrames, endFrame);
    return preComps;
  });
}


List<Layer> parseLayers(List rawLayers, double width, double height,
    double scale, double durationFrames, int endFrame) {
  return rawLayers.map((rawLayer) =>
  new Layer(rawLayer, width, height, scale,
      durationFrames == null ? 0.0 : durationFrames, endFrame))
      .toList();
}

