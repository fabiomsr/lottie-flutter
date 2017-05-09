import 'dart:convert';
import 'package:Lotie_Flutter/src/animatables.dart';
import 'package:test/test.dart';

void main() {
  test('animatable integer without keyframes test', () {
    Map map = JSON.decode('{"a":0,"k":200}');
    var animatableValue = new AnimatableIntegerValue.fromMap(map);
    expect(animatableValue.initialValue, 200);
  });

  test('animatable integer without keyframes and a array test', () {
    Map map = JSON.decode('{"a":0,"k":[300,100,100]}');
    var animatableValue = new AnimatableIntegerValue.fromMap(map);
    expect(animatableValue.initialValue, 300);
    expect(animatableValue.scene.keyframes.length, 0);
  });

  test('animatable integer without keyframes and an array of doubles test', () {
    Map map = JSON.decode('{"a":0,"k":[0.153,0.624,0.937,1]}');
    var animatableValue = new AnimatableIntegerValue.fromMap(map);
    expect(animatableValue.initialValue, 0);
    expect(animatableValue.scene.keyframes.length, 0);
  });

  test('animatable integer with keyframes test', () {
    Map map = JSON.decode('{"a":0,"k":['
        '{"t":16, "s":[352,280,0],"e":[352,299,0]} ]}');
    var animatableValue = new AnimatableIntegerValue.fromMap(map);
    expect(animatableValue.initialValue, 352);
    expect(animatableValue.scene.keyframes.length, 1);
  });
}