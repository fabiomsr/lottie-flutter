import 'package:Lotie_Flutter/model/GradientColor.dart';
import 'package:Lotie_Flutter/model/Keyframe.dart';
import 'package:Lotie_Flutter/model/Scene.dart';
import 'package:Lotie_Flutter/utils/Maths.dart';
import 'package:flutter/material.dart';

class Parsers {

  static const ColorParser colorParser = const ColorParser();
  static const IntParser intParser = const IntParser();
  static const DoubleParser doubleParser = const DoubleParser();
}


abstract class Parser<V> {
  V parse(dynamic map, double scale);
}


class IntParser implements Parser<int> {
  const IntParser();

  @override
  int parse(dynamic map, double scale) {
    return map * scale;
  }

}

class DoubleParser implements Parser<double> {
  const DoubleParser();

  @override
  double parse(dynamic map, double scale) {
    return map * scale;
  }

}

class ColorParser implements Parser<Color> {

  const ColorParser();

  Color parse(dynamic map, double scale) {
    if (map == null || map.length != 4) {
      return Colors.black;
    }

    bool shouldUse255 = true;
    for (double colorChannel in map) {
      if (colorChannel > 1) {
        shouldUse255 = false;
      }
    }

    final double multiplier = shouldUse255 ? 255.0 : 1.0;
    final int alpha = map[3] * multiplier;
    final int red = map[0] * multiplier;
    final int green = map[1] * multiplier;
    final int blue = map[2] * multiplier;
    return new Color.fromARGB(alpha, red, green, blue);
  }
}


class GradientColorParser extends Parser<GradientColor> {

  final int _colorPoints;

  GradientColorParser(this._colorPoints);

  // Both the color stops and opacity stops are in the same array.
  // There are [colorPoints] colors sequentially as:
  // [ ..., position, red, green, blue, ... ]
  //
  //  The remainder of the array is the opacity stops sequentially as:
  //
  // [ ..., position, opacity, ... ]
  @override
  GradientColor parse(dynamic map, double scale) {
    List rawGradientColor = map as List;
    final List<double> positions = new List(_colorPoints);
    final List<Color> colors = new List(_colorPoints);
    final GradientColor gradientColor = new GradientColor(positions, colors);

    if (rawGradientColor.length != _colorPoints * 4) {
      debugPrint("Unexpected gradient length: ${rawGradientColor.length}"
          ". Expected ${_colorPoints *
          4} . This may affect the appearance of the gradient. "
          "Make sure to save your After Effects file before exporting an animation with "
          "gradients.");
    }

    for (int i = 0; i < _colorPoints * 4; i += 4) {
      int colorIndex = i ~/ 4;
      positions[colorIndex] = rawGradientColor[i];
      colors[colorIndex] = new Color.fromARGB(255,
          rawGradientColor[i + 1] * 255,
          rawGradientColor[i + 2] * 255,
          rawGradientColor[i + 3] * 255);
    }

    _addOpacityStopsToGradientIfNeeded(gradientColor, rawGradientColor);
    return gradientColor;
  }


  // This cheats a little bit.
  // Opacity stops can be at arbitrary intervals independent of color stops.
  // This uses the existing color stops and modifies the opacity at each existing color stop
  // based on what the opacity would be.
  //
  // This should be a good approximation is nearly all cases. However, if there are many more
  // opacity stops than color stops, information will be lost.
  void _addOpacityStopsToGradientIfNeeded(GradientColor gradientColor,
      List rawGradientColor) {
    final int startIndex = _colorPoints * 4;
    if (rawGradientColor.length <= startIndex) {
      return;
    }

    final int opacityStops = (rawGradientColor.length - startIndex) ~/ 2;
    final List<double> positions = new List<double>(opacityStops);
    final List<double> opacities = new List<double>(opacityStops);

    for (int i = startIndex, j = 0; i < rawGradientColor.length; i += 2, j++) {
      positions[j] = rawGradientColor[i];
      opacities[j] = rawGradientColor[i + 1];
    }

    for (int i = 0; i < gradientColor.length; i++) {
      final Color color = gradientColor.colors[i];
      Color colorWithAlpha = color.withAlpha(_getOpacityAtPosition(
          gradientColor.positions[i], positions, opacities));
      gradientColor.colors[i] = colorWithAlpha;
    }
  }

  int _getOpacityAtPosition(double position, List<double> positions,
      List<double> opacities) {
    for (int i = 1; i < positions.length; i++) {
      double lastPosition = positions[i - 1];
      double thisPosition = positions[i];
      if (positions[i] >= position) {
        double progress = (position - lastPosition) /
            (thisPosition - lastPosition);
        return (255 * lerp(opacities[i - 1], opacities[i], progress)).toInt();
      }
    }

    return (255 * opacities[opacities.length - 1]).toInt();
  }

}


class AnimatableValueParser<T> {

  KeyframeGroup<T> parse(dynamic map, Parser<T> parser, double scale) {
    Scene scene = _parseKeyframes(map, parser, scale);
    T initialValue = _parseInitialValue(map, scene.keyframes, parser, scale);
    return new KeyframeGroup(initialValue, scene);
  }

  Scene _parseKeyframes(dynamic map, Parser<T> parser, double scale) {
    return new Scene.fromMap(map, parser, scale);
  }

  T _parseInitialValue(dynamic map, List<Keyframe<T>> keyframes,
      Parser<T> parser, scale) {
    if (map == null) {
      return null;
    }

    return keyframes.isNotEmpty ? keyframes.first.startValue : parser.parse(
        map['k'], scale);
  }

}

class KeyframeGroup<T> {
  final Scene scene;
  final T initialValue;

  KeyframeGroup(this.initialValue, this.scene);
}