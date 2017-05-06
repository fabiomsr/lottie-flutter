import 'dart:math' show Point;

import 'package:Lotie_Flutter/utils/Maths.dart';
import 'package:flutter/painting.dart' as paint show Path,Offset;



class PointF extends paint.Offset {
  const PointF([double x = 0.0, double y = 0.0]) : super(x, y);

  double get x => dx;
  double get y => dy;

  PointF scaleXY(double value) => scale(value, value);
}

class Path extends paint.Path {
  Path(PointF start, PointF end, PointF cp1, PointF cp2) : super() {
    moveTo(start.x, start.y);

    if (cp1 != null && cp2 != null &&
        (cp1.distance != 0 || cp2.distance != 0)) {
      cubicTo(start.x + cp1.x, start.y + cp1.y,
          end.x + cp2.x, end.y + cp2.y,
          end.x, end.y);
    } else {
      lineTo(end.x, end.y);
    }
  }

  Path.fromShape(ShapeData shapeData) : super() {
    PointF initialPoint = shapeData.initialPoint;
    moveTo(initialPoint.x, initialPoint.y);

    for(var curve in shapeData.curves) {
      cubicTo(curve.controlPoint1.x, curve.controlPoint1.y,
          curve.controlPoint2.x, curve.controlPoint2.y,
          curve.vertex.x, curve.vertex.y);
    }

    if(shapeData.isClosed) {
      close();
    }
  }

}


class CubicCurveData {
  final PointF _controlPoint1;
  final PointF _controlPoint2;
  final PointF _vertex;

  PointF get controlPoint1 => _controlPoint1;

  PointF get controlPoint2 => _controlPoint2;

  PointF get vertex => _vertex;


  CubicCurveData(this._controlPoint1, this._controlPoint2, this._vertex);
}


class ShapeData {
  List<CubicCurveData> _curves;
  bool _isClosed;
  PointF _initialPoint;

  bool get isClosed => _isClosed;

  PointF get initialPoint => _initialPoint;

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
        shapeData1.initialPoint.x, shapeData2.initialPoint.y, percentage);
    double y = lerp(
        shapeData1.initialPoint.y, shapeData2.initialPoint.y, percentage);
    _initialPoint = new PointF(x, y);

    for (int i = 0; i < shapeData1.length; i++) {
      CubicCurveData curve1 = shapeData1.curves[i];
      CubicCurveData curve2 = shapeData2.curves[i];

      double x1 = lerp(
          curve1.controlPoint1.x, curve2.controlPoint1.x, percentage);
      double y1 = lerp(
          curve1.controlPoint1.y, curve2.controlPoint1.y, percentage);

      double x2 = lerp(
          curve1.controlPoint2.x, curve2.controlPoint2.x, percentage);
      double y2 = lerp(
          curve1.controlPoint2.y, curve2.controlPoint2.y, percentage);

      double vertexX = lerp(curve1.vertex.x, curve2.vertex.x, percentage);
      double vertexY = lerp(curve1.vertex.y, curve2.vertex.y, percentage);

      CubicCurveData curve = new CubicCurveData(
          new PointF(x1, y1), new PointF(x2, y2), new PointF(vertexX, vertexY));
      _curves.add(curve);
    }
  }

}