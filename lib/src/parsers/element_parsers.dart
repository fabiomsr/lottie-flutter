import 'dart:ui';
import 'package:Lotie_Flutter/src/animatables.dart';
import 'package:Lotie_Flutter/src/values.dart';

String parseName(dynamic map) => map['nm'];

AnimatableColorValue parseColor(dynamic map, double durationFrames) =>
    map['c'] == null ? null : new AnimatableColorValue.fromMap(
        map['c'], durationFrames);

AnimatableIntegerValue parseOpacity(dynamic map, double durationFrames) =>
    map['o'] == null ? null : new AnimatableIntegerValue.fromMap(
        map['o'], durationFrames);

AnimatableDoubleValue parseWidth(dynamic map, double scale,
    double durationFrames) =>
    new AnimatableDoubleValue.fromMap(map['w'], scale, durationFrames);

AnimatableGradientColorValue parseGradient(dynamic map, double durationFrames) {
  Map rawColor = map['g'];

  if (rawColor != null && rawColor.containsKey('k')) {
    int points = rawColor['p'];
    rawColor = rawColor['k'];
    if (points != null) {
      rawColor['p'] = points;
    }
  }

  return rawColor == null ? null : new AnimatableGradientColorValue.fromMap(
      rawColor, durationFrames);
}

AnimatablePointValue parseStartPoint(dynamic map, double scale,
    double durationFrames) =>
    parsePoint(map['s'], scale, durationFrames);

AnimatablePointValue parseEndPoint(dynamic map, double scale,
    double durationFrames) =>
    parsePoint(map['e'], scale, durationFrames);

AnimatablePointValue parsePoint(dynamic map, double scale,
    double durationFrames) =>
    map == null ? null : new AnimatablePointValue.fromMap(
        map, scale, durationFrames);

AnimatablePointValue parseSize(dynamic map, double scale,
    double durationFrames) =>
    new AnimatablePointValue.fromMap(map['s'], scale, durationFrames);

AnimatableDoubleValue parseinnerRadius(dynamic map, scale,
    double durationFrames) =>
    map['ir'] == null ? null
        : new AnimatableDoubleValue.fromMap(map['ir'], scale, durationFrames);

AnimatableDoubleValue parseInnerRoundness(dynamic map, double durationFrames) =>
    map['is'] == null ? null
        : new AnimatableDoubleValue.fromMap(map['is'], 1.0, durationFrames);

parseCapType(dynamic map) => StrokeCap.values[map['lc'] - 1];

StrokeJoin parseJoinType(dynamic map) => StrokeJoin.values[map['lj'] - 1];

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


LineDashGroup parseLineDash(dynamic map, double scale, double durationFrames) {
  AnimatableDoubleValue offset;
  final lineDashPattern = new List<AnimatableDoubleValue>();

  if (map.contains('d')) {
    List rawDashes = map['d'];
    for (var rawDash in rawDashes) {
      final String n = rawDash['n'];
      if (n == 'o') {
        offset =
        new AnimatableDoubleValue.fromMap(rawDash['v'], scale, durationFrames);
      } else if (n == 'd' || n == 'g') {
        lineDashPattern.add(
            new AnimatableDoubleValue.fromMap(
                rawDash['v'], scale, durationFrames));
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
    double scale, double durationFrames) {
  final rawPosition = map['p'];

  return rawPosition.containsKey('k') ? new AnimatablePathValue(rawPosition['k'], scale, durationFrames)
      : new AnimatableSplitDimensionValue(
      new AnimatableDoubleValue.fromMap(rawPosition['x'], scale, durationFrames),
      new AnimatableDoubleValue.fromMap(rawPosition['y'], scale, durationFrames));
}


class LineDashGroup {
  final AnimatableDoubleValue _offset;
  final List<AnimatableDoubleValue> _lineDashPattern;

  AnimatableDoubleValue get offset => _offset;

  List<AnimatableDoubleValue> get lineDashPattern => _lineDashPattern;

  LineDashGroup(this._offset, this._lineDashPattern);
}