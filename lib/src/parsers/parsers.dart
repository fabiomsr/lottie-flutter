import 'dart:ui';
import 'package:Lotie_Flutter/src/mathutils.dart';

import 'package:Lotie_Flutter/src/values.dart';



class Parsers {

  static const ColorParser colorParser = const ColorParser();
  static const IntParser intParser = const IntParser();
  static const DoubleParser doubleParser = const DoubleParser();
  static const PointFParser pointFParser = const PointFParser();
  static const ScaleParser scaleParser = const ScaleParser();
  static const ShapeDataParser shapeDataParser = const ShapeDataParser();
  static const PathParser pathParser = const PathParser();
}


abstract class Parser<V> {
  V parse(dynamic map, double scale);
}

double parseMapToDouble(dynamic map) {
  double value = 0.0;

  if (map is List && map.isNotEmpty) {
    value = map[0] is int ? map[0].toDouble() : map[0];
  } else if (map is int) {
    value = map.toDouble();
  } else if (map is double) {
    value = map;
  }

  return value;
}

class IntParser implements Parser<int> {
  const IntParser();

  @override
  int parse(dynamic map, double scale) =>
      (parseMapToDouble(map) * scale).toInt();
}

class DoubleParser implements Parser<double> {
  const DoubleParser();

  @override
  double parse(dynamic map, double scale) => parseMapToDouble(map) * scale;
}

class PointFParser implements Parser<Offset> {

  const PointFParser();

  @override
  Offset parse(dynamic json, double scale) {
    if (json == null) {
      return null;
    }

    if (json is List && json.length >= 2) {
      return new Offset(json[0] * scale, json[1] * scale);
    }

    if (json is Map) {
      return new Offset(parseMapToDouble(json['x']) * scale,
          parseMapToDouble(json['y']) * scale);
    }

    throw new ArgumentError.value(json, "json", "Unable to parse point");
  }
}

class ScaleParser implements Parser<Offset> {

  const ScaleParser();

  @override
  Offset parse(dynamic list, double scale) =>
      new Offset(list[0] / 100.0 * scale, list[1] / 100.0 * scale);
}


class ColorParser implements Parser<Color> {

  const ColorParser();

  Color parse(dynamic map, double scale) {
    if (map == null || map.length != 4) {
      return const Color(0x0);
    }



    bool shouldUse255 = true;
    List<double> rawColors = [];
    for(int i = 0; i < 4; i++ ) {
      double colorChannel = map[i] is int ? map[i].toDouble() : map[i];
      if (colorChannel > 1) {
        shouldUse255 = false;
      }
      rawColors.add(colorChannel);
    }

    final double multiplier = shouldUse255 ? 255.0 : 1.0;
    final int alpha = (map[3] * multiplier).toInt();
    final int red = (map[0] * multiplier).toInt();
    final int green = (map[1] * multiplier).toInt();
    final int blue = (map[2] * multiplier).toInt();

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
      return new ShapeData(const [], Offset.zero, false);
    }

    Offset initialPoint = _vertexAtIndex(0, points).scale(scale, scale);
    List<CubicCurveData> curves = new List<CubicCurveData>(closed ? points.length
                                                                  : points.length - 1);

    for (int i = 1; i < points.length; i++) {
      Offset vertex = _vertexAtIndex(i, points);
      Offset previousVertex = _vertexAtIndex(i - 1, points);
      Offset cp1 = _vertexAtIndex(i - 1, outTangents);
      Offset cp2 = _vertexAtIndex(i, inTangents);
      Offset shapeCp1 = (previousVertex + cp1).scale(scale, scale);
      Offset shapeCp2 = (vertex + cp2).scale(scale, scale);
      Offset scaleVertex = vertex.scale(scale, scale);

      curves[i - 1] = new CubicCurveData(shapeCp1, shapeCp2, scaleVertex);
    }

    if (closed) {
      Offset vertex = _vertexAtIndex(0, points);
      Offset previousVertex = _vertexAtIndex(points.length - 1, points);
      Offset cp1 = _vertexAtIndex(points.length - 1, outTangents);
      Offset cp2 = _vertexAtIndex(0, inTangents);

      Offset shape1 = (previousVertex + cp1).scale(scale, scale);
      Offset shape2 = (vertex + cp2).scale(scale, scale);
      Offset scaleVertex = vertex.scale(scale, scale);
      curves[curves.length - 1] = new CubicCurveData(shape1, shape2, scaleVertex);
    }

    return  new ShapeData(curves, initialPoint, closed);
  }

  Offset _vertexAtIndex(int index, List points) {
    return new Offset(parseMapToDouble(points[index][0]),
                      parseMapToDouble(points[index][1]));
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

    for (int i = 0; i < rawGradientColor.length; i += 4) {
      int colorIndex = i ~/ 4;
      positions[colorIndex] = rawGradientColor[i];
      colors[colorIndex] = new Color.fromARGB(255,
          (parseMapToDouble(rawGradientColor[i + 1]) * 255).toInt(),
          (parseMapToDouble(rawGradientColor[i + 2] * 255)).toInt(),
          (parseMapToDouble(rawGradientColor[i + 3] * 255)).toInt());
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


class PathParser implements Parser<Path> {

  const PathParser();

  @override
  Path parse(map, double scale) {
    return new Path();
  }

  Path parseFromShape(ShapeData shapeData) {
    Path path = new Path();
    Offset initialPoint = shapeData.initialPoint;
    path.moveTo(initialPoint.dx, initialPoint.dy);

    for (var curve in shapeData.curves) {
      path.cubicTo(curve.controlPoint1.dx, curve.controlPoint1.dy,
          curve.controlPoint2.dx, curve.controlPoint2.dy,
          curve.vertex.dx, curve.vertex.dy);
    }

    if (shapeData.isClosed) {
      path.close();
    }

    return path;
  }

}


