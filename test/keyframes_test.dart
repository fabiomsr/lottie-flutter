import 'dart:convert';
import 'package:Lotie_Flutter/src/keyframes.dart';
import 'package:Lotie_Flutter/src/parsers.dart';
import 'package:Lotie_Flutter/src/values.dart';
import 'package:flutter/animation.dart' show Curves, Cubic;
import 'package:flutter/painting.dart' show Color;
import 'package:test/test.dart';

void main() {


  ///
  /// Integer keyframe
  ///

  test('keyframe of integer with h test', () {
    Map map = JSON.decode('{"t":16, "h":1, "s":[352,280,0],"e":[400,299,0]}');
    _expect(map, Parsers.intParser, 352, 352, equals(Curves.linear));
  });

  test('keyframe of integer test', () {
    Map map = JSON.decode('{"t":16, "s":[352,280,0],"e":[400,299,0]}');
    _expect(map, Parsers.intParser, 352, 400, equals(Curves.linear));
  });

  test('keyframe of integer with curve test', () {
    Map map = JSON.decode('{"t":16, "s":[352,280,0], "e":[400,299,0],'
        '"o":{"x":[0.333,0.333,0.333],"y":[0.333,0,0.333]},'
        '"i":{"x":[0.667,0.667,0.667],"y":[0.667,1,0.667]}}');
    _expect(map, Parsers.intParser, 352, 400, new isInstanceOf<Cubic>());
  });


  ///
  /// Double keyframe
  ///

  test('keyframe of double with h test', () {
    Map map = JSON.decode(
        '{"t":16, "h":1, "s":[352.5,280,0],"e":[400.3,299,0]}');
    _expect(map, Parsers.doubleParser, 352.5, 352.5, equals(Curves.linear));
  });

  test('keyframe of double test', () {
    Map map = JSON.decode('{"t":16, "s":[352.3,280,0],"e":[400.5,299,0]}');
    _expect(map, Parsers.doubleParser, 352.3, 400.5, equals(Curves.linear));
  });

  test('keyframe of double with curve test', () {
    Map map = JSON.decode('{"t":16, "s":[352.3,280,0], "e":[400,299,0],'
        '"o":{"x":[0.333,0.333,0.333],"y":[0.333,0,0.333]},'
        '"i":{"x":[0.667,0.667,0.667],"y":[0.667,1,0.667]}}');
    _expect(map, Parsers.doubleParser, 352.3, 400.0, new isInstanceOf<Cubic>());
  });


  ///
  /// Point keyframe
  ///

  test('keyframe of point as list with h test', () {
    Map map = JSON.decode(
        '{"t":16, "h":1, "s":[352.5,280,0],"e":[400.3,299,0]}');
    _expectPointKeyframe(map, 352.5, 280.0);
  });

  test('keyframe of point as map with h test', () {
    Map map = JSON.decode(
        '{"t":16, "h":1, "s":{"x":352.5,"y":280},"e":{"x":400.3,"y":299}}');
    _expectPointKeyframe(map, 352.5, 280.0);
  });

  test('keyframe of point as list test', () {
    Map map = JSON.decode('{"t":16, "s":[352.5,280,0],"e":[400.3,299,0]}');
    _expectPointKeyframe(map, 352.5, 280.0, x2: 400.3, y2: 299.0);
  });

  test('keyframe of point as map test', () {
    Map map = JSON.decode(
        '{"t":16, "s":{"x":352.5,"y":280},"e":{"x":400.3,"y":299}}');
    _expectPointKeyframe(map, 352.5, 280.0, x2: 400.3, y2: 299.0);
  });

  test('keyframe of point as list with curve test', () {
    Map map = JSON.decode('{"t":16, "s":[352.3,280,0], "e":[400,299,0],'
        '"o":{"x":[0.333,0.333,0.333],"y":[0.333,0,0.333]},'
        '"i":{"x":[0.667,0.667,0.667],"y":[0.667,1,0.667]}}');
    _expectPointKeyframe(map, 352.3, 280.0, x2:400.0, y2:299.0,
        curveMatcher: new isInstanceOf<Cubic>());
  });

  test('keyframe of point as map with curve test', () {
    Map map = JSON.decode('{"t":16, "s":[352.3,280,0], "e":[400,299,0],'
        '"o":{"x":[0.333,0.333,0.333],"y":[0.333,0,0.333]},'
        '"i":{"x":[0.667,0.667,0.667],"y":[0.667,1,0.667]}}');
    _expectPointKeyframe(map, 352.3, 280.0, x2: 400.0, y2: 299.0,
        curveMatcher: new isInstanceOf<Cubic>());
  });

  ///
  /// Scale keyframe
  ///

  test('Scale keyframe with h test', () {
    Map map = JSON.decode(
        '{"t":16, "h":1, "s":[352.5,280,0],"e":[400.3,299,0]}');
    _expectPointKeyframe(map, 3.525, 2.8, parser: Parsers.scaleParser);
  });

  test('Scale keyframe test', () {
    Map map = JSON.decode('{"t":16, "s":[352.31,280,0],"e":[400.5,299,0]}');
    _expectPointKeyframe(map, 3.5231, 2.8, x2:4.005, y2: 2.99, parser: Parsers.scaleParser);
  });

  test('Scale keyframe with curve test', () {
    Map map = JSON.decode('{"t":16, "s":[352.3,280,0], "e":[400,299,0],'
        '"o":{"x":[0.333,0.333,0.333],"y":[0.333,0,0.333]},'
        '"i":{"x":[0.667,0.667,0.667],"y":[0.667,1,0.667]}}');
    _expectPointKeyframe(map, 3.523, 2.8, x2:4.0, y2: 2.99,
        curveMatcher: new isInstanceOf<Cubic>(), parser: Parsers.scaleParser);
  });


  ///
  /// Color keyframe
  ///

  test('Color keyframe with h test', () {
    Map map = JSON.decode(
        '{"t":16, "h":1, "s":[0.12,0.67,0.54,1.0],"e":[213,20,110,1] }');
    var expected = const Color.fromARGB(255, 30, 170, 137);
    _expect(map, Parsers.colorParser, expected, expected, equals(Curves.linear));
  });

  test('Color keyframe test', () {
    Map map = JSON.decode('{"t":16, "s":[0.12,0.67,0.54,1.0],"e":[213,20,110,1] }');
    var startValueExpected = const Color.fromARGB(255, 30, 170, 137);
    var endValueExpected = const Color.fromARGB(1, 213, 20, 110);
    _expect(map, Parsers.colorParser, startValueExpected, endValueExpected,
        equals(Curves.linear));
  });

  test('Color keyframe with curve test', () {
    Map map = JSON.decode('{"t":16,"s":[0.12,0.67,0.54,1.0],"e":[213,20,110,1],'
        '"o":{"x":[0.333,0.333,0.333],"y":[0.333,0,0.333]},'
        '"i":{"x":[0.667,0.667,0.667],"y":[0.667,1,0.667]}}');
    var startValueExpected = const Color.fromARGB(255, 30, 170, 137);
    var endValueExpected = const Color.fromARGB(1, 213, 20, 110);
    _expect(map, Parsers.colorParser, startValueExpected, endValueExpected,
        new isInstanceOf<Cubic>());
  });

}




void _expectPointKeyframe<T>(dynamic map, double x1, double y1,
    {double x2, double y2, Matcher curveMatcher, Parser<T> parser}) {
  var startValueExpected = new PointF(x1, y1);
  var endValueExpected = new PointF(x2 ?? x1, y2 ?? y1);
  _expect(map, parser ?? Parsers.pointFParser, startValueExpected, endValueExpected,
      curveMatcher ?? equals(Curves.linear));
}

void _expect<T>(dynamic map, Parser<T> parser, T startValue, T endValue,
    Matcher curveMatcher) {
  var keyframe = new Keyframe<T>.fromMap(map, parser, 1.0);
  expect(keyframe.startValue, startValue);
  expect(keyframe.endValue, endValue);
  expect(keyframe.curve, curveMatcher);
}