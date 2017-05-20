import 'package:Lotie_Flutter/src/animatables.dart';
import 'package:Lotie_Flutter/src/values.dart';
import 'package:flutter/painting.dart' show Offset, PathFillType, StrokeCap;

String parseName(dynamic map) => map['nm'];

AnimatableColorValue parseColor(dynamic map) =>
    map['c'] == null ? null : new AnimatableColorValue.fromMap(map['c']);

AnimatableIntegerValue parseOpacity(dynamic map) =>
    map['o'] == null ? null : new AnimatableIntegerValue.fromMap(map['o']);

AnimatableDoubleValue parseWidth(dynamic map, double scale) =>
    new AnimatableDoubleValue.fromMap(map['w'], scale);

AnimatableGradientColorValue parseGradient(dynamic map) {
  Map rawColor = map['g'];

  if (rawColor != null && rawColor.containsKey('k')) {
    int points = rawColor['p'];
    rawColor = rawColor['k'];
    if (points != null) {
      rawColor['p'] = points;
    }
  }

  return rawColor == null ? null : new AnimatableGradientColorValue.fromMap(
      rawColor);
}

AnimatablePointValue parseStartPoint(dynamic map, double scale) =>
    parsePoint(map['s'], scale);

AnimatablePointValue parseEndPoint(dynamic map, double scale) =>
    parsePoint(map['e'], scale);

AnimatablePointValue parsePoint(dynamic map, double scale) =>
    map == null ? null : new AnimatablePointValue.fromMap(map, scale);

AnimatablePointValue parseSize(dynamic map, double scale) =>
    new AnimatablePointValue.fromMap(map['s'], scale);

AnimatableDoubleValue parseinnerRadius(dynamic map, scale) =>
    map['ir'] == null ? null
        : new AnimatableDoubleValue.fromMap(map['ir'], scale);

AnimatableDoubleValue parseInnerRoundness(dynamic map, scale) =>
    map['is'] == null ? null
        : new AnimatableDoubleValue.fromMap(map['is'], scale);

parseCapType(dynamic map) => StrokeCap.values[map['lc'] - 1];

JoinType parseJoinType(dynamic map) => JoinType.values[map['lj'] - 1];

GradientType parseGradientType(dynamic map) =>
    map['t'] == null || map['t'] == 1
        ? GradientType.Linear : GradientType.Radial;

PathFillType parseFillType(dynamic map) =>
    map['r'] == null || map['r'] == 1
        ? PathFillType.nonZero : PathFillType.evenOdd;

ShapeTrimPathType parseShapeTrimPathType(dynamic map) {
  int rawType = map['m'] ?? 1;
  switch (rawType) {
    case 1:
      return ShapeTrimPathType.Simultaneously;
    case 2:
      return ShapeTrimPathType.Individually;
    default:
      throw new ArgumentError.value(
          rawType, "ShapeTrimPathType", "Unknow trim Path");
  }
}

PolystarShapeType parserPolystarShapeType(dynamic map) {
  int rawType = map['sy'];
  switch (rawType) {
    case 1:
      return PolystarShapeType.Star;
    case 2:
      return PolystarShapeType.Polygon;
    default:
      return null;
  }
}

MergePathsMode parseMergePathsMode(dynamic map) {
  int rawMode = map['mm'] ?? 1;
  switch (rawMode) {
    case 1:
      return MergePathsMode.Merge;
    case 2:
      return MergePathsMode.Add;
    case 3:
      return MergePathsMode.Subtract;
    case 4:
      return MergePathsMode.Intersect;
    case 5:
      return MergePathsMode.ExcludeIntersections;
    default:
      return MergePathsMode.Merge;
  }
}


LineDashGroup parseLineDash(dynamic map, double scale) {
  AnimatableDoubleValue offset;
  final lineDashPattern = new List<AnimatableDoubleValue>();

  if (map.contains('d')) {
    List rawDashes = map['d'];
    for (var rawDash in rawDashes) {
      final String n = rawDash['n'];
      if (n == 'o') {
        offset = new AnimatableDoubleValue.fromMap(rawDash['v'], scale);
      } else if (n == 'd' || n == 'g') {
        lineDashPattern.add(
            new AnimatableDoubleValue.fromMap(rawDash['v'], scale));
      }
    }

    if (lineDashPattern.length == 1) {
      // If there is only 1 value then it is assumed to be equal parts on and off.
      lineDashPattern.add(lineDashPattern[0]);
    }
  }

  return new LineDashGroup(offset, lineDashPattern);
}


AnimatableValue<Offset> parsePathOrSplitDimensionPath(dynamic map,
    double scale) {
  final rawPosition = map['p'];

  if (rawPosition is Map) {
    return map.containsKey('k') ? new AnimatablePathValue(map['k'], scale)
        : new AnimatableSplitDimensionValue(
        new AnimatableDoubleValue.fromMap(map['x'], scale),
        new AnimatableDoubleValue.fromMap(map['y'], scale));
  }

  return null;
}


class LineDashGroup {
  final AnimatableDoubleValue _offset;
  final List<AnimatableDoubleValue> _lineDashPattern;

  AnimatableDoubleValue get offset => _offset;

  List<AnimatableDoubleValue> get lineDashPattern => _lineDashPattern;

  LineDashGroup(this._offset, this._lineDashPattern);
}