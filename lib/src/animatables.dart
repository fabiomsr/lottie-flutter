import 'dart:ui' show Color, Offset, Path;
import 'package:lottie_flutter/src/values.dart';
import 'package:lottie_flutter/src/animations.dart';
import 'package:lottie_flutter/src/keyframes.dart';
import 'package:lottie_flutter/src/parsers/parsers.dart';


abstract class AnimatableValue<A> {
  BaseKeyframeAnimation<dynamic, A> createAnimation();
  bool get hasAnimation;
}

abstract class BaseAnimatableValue<V, O> implements AnimatableValue<O> {
  final V _initialValue;
  final Scene<V> _scene;

  bool get hasAnimation => _scene.hasAnimation;

  V get initialValue => _initialValue;

  Scene<V> get scene => _scene;

  BaseAnimatableValue([this._initialValue, Scene scene])
      : _scene = scene ?? new Scene.empty();

  BaseAnimatableValue.fromKeyframeGroup(KeyframeGroup keyframeGroup)
      : _initialValue = keyframeGroup.initialValue,
        _scene = keyframeGroup.scene;
}

//
//  Integer
//
class AnimatableIntegerValue extends BaseAnimatableValue<int, int> {
  static final AnimatableValueParser _parser = new AnimatableValueParser<int>();

  AnimatableIntegerValue([int initialValue = 100, Scene scene])
      : super(initialValue, scene);

  AnimatableIntegerValue.fromMap(dynamic map, double durationFrames)
      : super.fromKeyframeGroup(
            _parser.parse(map, Parsers.intParser, 1.0, durationFrames));

  @override
  KeyframeAnimation<int> createAnimation() {
    return hasAnimation
        ? new IntegerKeyframeAnimation(scene)
        : new StaticKeyframeAnimation(initialValue);
  }
}

//
//  Double
//
class AnimatableDoubleValue extends BaseAnimatableValue<double, double> {
  static final AnimatableValueParser _parser =
      new AnimatableValueParser<double>();

  AnimatableDoubleValue() : super(0.0, new Scene.empty());

  AnimatableDoubleValue.fromMap(
      dynamic map, double scale, double durationFrames)
      : super.fromKeyframeGroup(
            _parser.parse(map, Parsers.doubleParser, scale, durationFrames));

  @override
  KeyframeAnimation<double> createAnimation() {
    return hasAnimation
        ? new DoubleKeyframeAnimation(scene)
        : new StaticKeyframeAnimation(initialValue);
  }
}

//
//  Color
//
class AnimatableColorValue extends BaseAnimatableValue<Color, Color> {
  static final AnimatableValueParser _parser =
      new AnimatableValueParser<Color>();

  AnimatableColorValue.fromMap(dynamic map, double durationFrames)
      : super.fromKeyframeGroup(
            _parser.parse(map, Parsers.colorParser, 1.0, durationFrames));

  @override
  KeyframeAnimation<Color> createAnimation() {
    return hasAnimation
        ? new ColorKeyframeAnimation(scene)
        : new StaticKeyframeAnimation(initialValue);
  }
}

//
//  GradientColor
//
class AnimatableGradientColorValue
    extends BaseAnimatableValue<GradientColor, GradientColor> {
  static final AnimatableValueParser _parser =
      new AnimatableValueParser<GradientColor>();

  AnimatableGradientColorValue.fromMap(dynamic map, double durationFrames)
      : super.fromKeyframeGroup(_parser.parse(
            map, new GradientColorParser(map['p']), 1.0, durationFrames));

  @override
  KeyframeAnimation<GradientColor> createAnimation() {
    return hasAnimation
        ? new GradientColorKeyframeAnimation(scene)
        : new StaticKeyframeAnimation(initialValue);
  }
}

//
//  Point
//
class AnimatablePointValue extends BaseAnimatableValue<Offset, Offset> {
  static final AnimatableValueParser _parser =
      new AnimatableValueParser<Offset>();

  AnimatablePointValue.fromMap(dynamic map, double scale, double durationFrames)
      : super.fromKeyframeGroup(
            _parser.parse(map, Parsers.pointFParser, scale, durationFrames));

  @override
  KeyframeAnimation<Offset> createAnimation() {
    return hasAnimation
        ? new PointKeyframeAnimation(scene)
        : new StaticKeyframeAnimation(initialValue);
  }
}

//
//  Scale
//
class AnimatableScaleValue extends BaseAnimatableValue<Offset, Offset> {
  static final AnimatableValueParser _parser =
      new AnimatableValueParser<Offset>();

  AnimatableScaleValue() : super(const Offset(1.0, 1.0), new Scene.empty());

  AnimatableScaleValue.fromMap(dynamic map, double durationFrames)
      : super.fromKeyframeGroup(
            _parser.parse(map, Parsers.scaleParser, 1.0, durationFrames));

  @override
  KeyframeAnimation<Offset> createAnimation() {
    return hasAnimation
        ? new ScaleKeyframeAnimation(scene)
        : new StaticKeyframeAnimation(initialValue);
  }
}

//
//  Shape
//
class AnimatableShapeValue extends BaseAnimatableValue<ShapeData, Path> {
  static final AnimatableValueParser _parser =
      new AnimatableValueParser<ShapeData>();

  AnimatableShapeValue.fromMap(dynamic map, double scale, double durationFrames)
      : super.fromKeyframeGroup(
            _parser.parse(map, Parsers.shapeDataParser, scale, durationFrames));

  @override
  BaseKeyframeAnimation<dynamic, Path> createAnimation() {
    return hasAnimation
        ? new ShapeKeyframeAnimation(scene)
        : new StaticKeyframeAnimation(
            Parsers.pathParser.parseFromShape(initialValue));
  }
}

//
//  Path
//
class AnimatablePathValue extends BaseAnimatableValue<Offset, Offset> {
  AnimatablePathValue._([Offset initialValue, Scene scene])
      : super(initialValue == null ? const Offset(0.0, 0.0) : initialValue,
            scene);

  factory AnimatablePathValue(
      [dynamic map, double scale, double durationFrames]) {
    if (map == null) {
      return new AnimatablePathValue._();
    }

    if (hasKeyframes(map)) {
      List rawKeyframes = map as List;
      List<Keyframe<Offset>> keyframes = rawKeyframes
          .map((rawKeyframe) =>
              new PathKeyframe.fromMap(rawKeyframe, scale, durationFrames))
          .toList();

      Scene scene = new Scene(keyframes);

      return new AnimatablePathValue._(null, scene);
    }

    return new AnimatablePathValue._(Parsers.pointFParser.parse(map, scale));
  }

  @override
  KeyframeAnimation<Offset> createAnimation() {
    return hasAnimation
        ? new PathKeyframeAnimation(scene)
        : new StaticKeyframeAnimation(initialValue);
  }
}

//
//  Split Dimension
//
class AnimatableSplitDimensionValue implements AnimatableValue<Offset> {
  final AnimatableDoubleValue _animatableXDimension;
  final AnimatableDoubleValue _animatableYDimension;

  AnimatableSplitDimensionValue(
      this._animatableXDimension, this._animatableYDimension);

  @override
  BaseKeyframeAnimation<dynamic, Offset> createAnimation() {
    return new SplitDimensionPathKeyframeAnimation(
        _animatableXDimension.createAnimation(),
        _animatableYDimension.createAnimation());
  }

  @override
  bool get hasAnimation =>
      _animatableXDimension.hasAnimation || _animatableYDimension.hasAnimation;
}

class AnimatableValueParser<T> {
  KeyframeGroup<T> parse(
      dynamic map, Parser<T> parser, double scale, double durationFrames) {
    Scene scene = _parseKeyframes(map, parser, scale, durationFrames);
    T initialValue = _parseInitialValue(map, scene.keyframes, parser, scale);
    return new KeyframeGroup(initialValue, scene);
  }

  Scene _parseKeyframes(
      dynamic map, Parser<T> parser, double scale, double durationFrames) {
    return new Scene.fromMap(map, parser, scale, durationFrames);
  }

  T _parseInitialValue(
      dynamic map, List<Keyframe<T>> keyframes, Parser<T> parser, scale) {
    if (keyframes.isNotEmpty) {
      return keyframes.first.startValue;
    }

    var rawInitialValue = map == null ? null : map['k'];

    return parser.parse(rawInitialValue, scale);
  }
}
