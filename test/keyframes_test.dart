import 'dart:convert';
import 'package:Lotie_Flutter/src/keyframes.dart';
import 'package:Lotie_Flutter/src/parsers.dart';
import 'package:flutter/animation.dart' show Curves, Cubic;
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

}

void _expect<T>(dynamic map, Parser<T> parser, T startValue, T endValue,
    Matcher curveMatcher) {
  var keyframe = new Keyframe<T>.fromMap(map, parser, 1.0);
  expect(keyframe.startValue, startValue);
  expect(keyframe.endValue, endValue);
  expect(keyframe.curve, curveMatcher);
}