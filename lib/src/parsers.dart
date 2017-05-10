import 'package:Lotie_Flutter/src/utils.dart';
import 'package:Lotie_Flutter/src/values.dart';
import 'package:flutter/material.dart' show Color, Colors;


class Parsers {

  static const ColorParser colorParser = const ColorParser();
  static const IntParser intParser = const IntParser();
  static const DoubleParser doubleParser = const DoubleParser();
  static const PointFParser pointFParser = const PointFParser();
  static const ScaleParser scaleParser = const ScaleParser();
  static const ShapeDataParser shapeDataParser = const ShapeDataParser();
}


abstract class Parser<V> {
  V parse(dynamic map, double scale);
}

double parseMapToDouble(dynamic map) {
  double value = 0.0;

  if(map is List && map.isNotEmpty) {
    value = map[0] is int ? map[0].toDouble() : map[0];
  } else if(map is int){
    value = map.toDouble();
  } else if(map is double){
    value = map;
  }

  return value;
}

class IntParser implements Parser<int> {
  const IntParser();

  @override
  int parse(dynamic map, double scale) => (parseMapToDouble(map) * scale).toInt();
}

class DoubleParser implements Parser<double> {
  const DoubleParser();

  @override
  double parse(dynamic map, double scale) => parseMapToDouble(map) * scale;
}

class PointFParser implements Parser<PointF> {

  const PointFParser();

  @override
  PointF parse(dynamic json, double scale) {
    if (json == null) {
      return null;
    }

    if (json is List && json.length >= 2) {
      return new PointF(json[0] * scale, json[1] * scale);
    }

    if (json is Map) {
      return new PointF(json['x'] * scale, json['y'] * scale);
    }

    throw new ArgumentError.value(json, "json", "Unable to parse point");
  }
}

class ScaleParser implements Parser<PointF> {

  const ScaleParser();

  @override
  PointF parse(dynamic list, double scale) {
    return new PointF(list[0] / 100.0 * scale, list[1] / 100.0 * scale);
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


class ShapeDataParser implements Parser<ShapeData> {

  const ShapeDataParser();

  @override
  ShapeData parse(dynamic json, double scale) {
    Map pointsData;

    if (json is List) {
      if (json[0] is Map && json[0].containsKey('v')) {
        pointsData = json[0];
      }
    } else if (json is Map && json.containsKey('v')) {
      pointsData = json;
    }

    if (pointsData == null) {
      return null;
    }

    List points = pointsData['v'];
    List inTangents = pointsData['i'];
    List outTangents = pointsData['o'];
    bool closed = pointsData['c'] ?? false;

    if (points == null || inTangents == null || outTangents == null ||
        points.length != inTangents.length ||
        points.length != outTangents.length) {
      throw new StateError(
          "Unable to process points array or tangets. $pointsData");
    } else if (points.isEmpty) {
      return new ShapeData(new List(0), new PointF(), false);
    }

    PointF initialPoint = _vertexAtIndex(0, points).scaleXY(scale);
    List<CubicCurveData> curves = new List<CubicCurveData>(points.length);

    for (int i = 1; i < points.length; i++) {
      PointF vertex = _vertexAtIndex(i, points);
      PointF previousVertex = _vertexAtIndex(i - 1, points);
      PointF cp1 = _vertexAtIndex(i - 1, outTangents);
      PointF cp2 = _vertexAtIndex(i, inTangents);
      PointF shapeCp1 = (previousVertex + cp1).scale(scale, scale);
      PointF shapeCp2 = (vertex + cp2).scale(scale, scale);
      PointF scaleVertex = vertex.scaleXY(scale);
      curves.add(new CubicCurveData(shapeCp1, shapeCp2, scaleVertex));
    }

    if (closed) {
      PointF vertex = _vertexAtIndex(0, points);
      PointF previousVertex = _vertexAtIndex(points.length, points);
      PointF cp1 = _vertexAtIndex(points.length - 1, outTangents);
      PointF cp2 = _vertexAtIndex(0, inTangents);

      PointF shape1 = (previousVertex + cp1).scale(scale, scale);
      PointF shape2 = (vertex + cp2).scale(scale, scale);
      PointF scaleVertex = vertex.scaleXY(scale);
      curves.add(new CubicCurveData(shape1, shape2, scaleVertex));
    }

    return new ShapeData(curves, initialPoint, closed);
  }

  PointF _vertexAtIndex(int index, List points) {
    return new PointF(points[index][0], points[index][1]);
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
      print("Unexpected gradient length: ${rawGradientColor.length}"
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


