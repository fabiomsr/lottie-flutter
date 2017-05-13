import 'package:Lotie_Flutter/src/utils.dart';
import 'package:collection/collection.dart' show IterableEquality;
import 'package:flutter/painting.dart' as paint show Path, Offset, Color;
import 'package:flutter/painting.dart' show hashValues, hashList;


class Path extends paint.Path {
  Path(paint.Offset start, paint.Offset end, paint.Offset cp1, paint.Offset cp2)
      : super() {
    moveTo(start.dx, start.dy);

    if (cp1 != null && cp2 != null &&
        (cp1.distance != 0 || cp2.distance != 0)) {
      cubicTo(start.dx + cp1.dx, start.dy + cp1.dy,
          end.dx + cp2.dx, end.dy + cp2.dy,
          end.dx, end.dy);
    } else {
      lineTo(end.dx, end.dy);
    }
  }

  Path.fromShape(ShapeData shapeData) : super() {
    paint.Offset initialPoint = shapeData.initialPoint;
    moveTo(initialPoint.dx, initialPoint.dy);

    for (var curve in shapeData.curves) {
      cubicTo(curve.controlPoint1.dx, curve.controlPoint1.dy,
          curve.controlPoint2.dx, curve.controlPoint2.dy,
          curve.vertex.dx, curve.vertex.dy);
    }

    if (shapeData.isClosed) {
      close();
    }
  }

}


class CubicCurveData {
  final paint.Offset _controlPoint1;
  final paint.Offset _controlPoint2;
  final paint.Offset _vertex;

  paint.Offset get controlPoint1 => _controlPoint1;

  paint.Offset get controlPoint2 => _controlPoint2;

  paint.Offset get vertex => _vertex;


  const CubicCurveData(this._controlPoint1, this._controlPoint2, this._vertex);

  @override
  bool operator ==(dynamic other) {
    if (other is! CubicCurveData)
      return false;
    final CubicCurveData typedOther = other;
    return _controlPoint1 == typedOther.controlPoint1 &&
        _controlPoint2 == typedOther.controlPoint2 &&
        _vertex == typedOther.vertex;
  }

  @override
  int get hashCode => hashValues(_controlPoint1, _controlPoint2, _vertex);

  @override
  String toString() {
    return 'CubicCurveData{controlPoint1: $_controlPoint1, '
        'controlPoint2: $_controlPoint2, vertex: $_vertex}';
  }


}


class ShapeData {
  List<CubicCurveData> _curves;
  bool _isClosed;
  paint.Offset _initialPoint;

  bool get isClosed => _isClosed;

  paint.Offset get initialPoint => _initialPoint;

  int get length => _curves.length;

  List<CubicCurveData> get curves => _curves;

  ShapeData(this._curves, this._initialPoint, this._isClosed);

  ShapeData.fromInterpolateBetween(ShapeData shapeData1, ShapeData shapeData2,
      double percentage) {
    _curves ??= new List<CubicCurveData>();

    if (_curves.isNotEmpty && curves.length != shapeData1.length &&
        _curves.length != shapeData2.length) {
      throw new StateError("Curves must have the same number of control point."
          "This: $length, Shape1: ${shapeData1.length}, Shape2: ${shapeData1
          .length}");
    }

    _isClosed = shapeData1.isClosed || shapeData2.isClosed;
    double x = lerp(
        shapeData1.initialPoint.dx, shapeData2.initialPoint.dy, percentage);
    double y = lerp(
        shapeData1.initialPoint.dy, shapeData2.initialPoint.dy, percentage);
    _initialPoint = new paint.Offset(x, y);

    for (int i = 0; i < shapeData1.length; i++) {
      CubicCurveData curve1 = shapeData1.curves[i];
      CubicCurveData curve2 = shapeData2.curves[i];

      double x1 = lerp(
          curve1.controlPoint1.dx, curve2.controlPoint1.dx, percentage);
      double y1 = lerp(
          curve1.controlPoint1.dy, curve2.controlPoint1.dy, percentage);

      double x2 = lerp(
          curve1.controlPoint2.dx, curve2.controlPoint2.dx, percentage);
      double y2 = lerp(
          curve1.controlPoint2.dy, curve2.controlPoint2.dy, percentage);

      double vertexX = lerp(curve1.vertex.dx, curve2.vertex.dx, percentage);
      double vertexY = lerp(curve1.vertex.dy, curve2.vertex.dy, percentage);

      CubicCurveData curve = new CubicCurveData(
          new paint.Offset(x1, y1), new paint.Offset(x2, y2),
          new paint.Offset(vertexX, vertexY));
      _curves.add(curve);
    }
  }

  @override
  bool operator ==(dynamic other) {
    if (other is! ShapeData)
      return false;
    final ShapeData typedOther = other;

    return _initialPoint == typedOther.initialPoint &&
        _isClosed == typedOther.isClosed &&
        const IterableEquality().equals(_curves,typedOther._curves);
  }

  @override
  int get hashCode => hashValues(length, isClosed, initialPoint);

  @override
  String toString() {
    return 'ShapeData{_isClosed: $_isClosed, _initialPoint: $_initialPoint,'
        'curves: $_curves}';
  }

}


class GradientColor {
  final List<double> _positions;
  final List<paint.Color> _colors;

  GradientColor(this._positions, this._colors);

  List<double> get positions => _positions;

  List<paint.Color> get colors => _colors;

  int get length => _colors.length;

  void lerpGradients(GradientColor gc1, GradientColor gc2, double progress) {
    if (gc1.length != gc2.length) {
      throw new ArgumentError(
          "Cannot interpolate between gradients. Lengths vary (${gc1
              .length} vs ${gc2.length})");
    }

    for (int i = 0; i < gc1.colors.length; i++) {
      positions[i] = lerp(gc1.positions[i], gc2.positions[i], progress);
      colors[i] =
          GammaEvaluator.evaluate(progress, gc1.colors[i], gc2.colors[i]);
    }
  }

  @override
  bool operator ==(dynamic other) {
    if (other is! GradientColor)
      return false;
    final GradientColor typedOther = other;

    return const IterableEquality().equals(_colors,typedOther.colors) &&
        const IterableEquality().equals(_positions,typedOther.positions);
  }

  @override
  int get hashCode => hashValues(hashList(_colors), hashList(_positions));

  @override
  String toString() {
    return 'GradientColor{_positions: $_positions, _colors: $_colors}';
  }


}