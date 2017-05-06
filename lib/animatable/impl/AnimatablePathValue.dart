import 'package:Lotie_Flutter/animatable/BaseAnimatableValue.dart';
import 'package:Lotie_Flutter/animation/KeyframeAnimation.dart';
import 'package:Lotie_Flutter/animation/impl/StaticKeyframeAnimation.dart';
import 'package:Lotie_Flutter/model/Keyframe.dart';
import 'package:Lotie_Flutter/model/AnimationValues.dart';
import 'package:Lotie_Flutter/model/Scene.dart';
import 'package:Lotie_Flutter/parser/Parser.dart';


class AnimatablePathValue extends BaseAnimatableValue<PointF, PointF> {

  static final AnimatableValueParser _parser = new AnimatableValueParser<PointF>();

  AnimatablePathValue._([PointF initialValue = const PointF(0.0, 0.0), Scene scene])
      : super(initialValue, scene:scene);


  factory AnimatablePathValue(dynamic map, double scale) {
    if(hasKeyframes(map)) {
      List rawKeyframes = map as List;
      List<Keyframe<PointF>> keyframes = rawKeyframes
          .map((rawKeyframe) => new _PathKeyframe.fromMap(rawKeyframe, scale))
          .toList();

      Scene scene = new Scene(keyframes);

      return new AnimatablePathValue._(null, scene);
    }

    return new AnimatablePathValue._(Parsers.pointFParser.parse(map, scale));
  }

  @override
  KeyframeAnimation<PointF> createAnimation() {
    return hasAnimation ? new _PathKeyframeAnimation(scene) :
                          new StaticKeyframeAnimation(initialValue);
  }
}


class _PathKeyframeAnimation extends KeyframeAnimation<PointF> {

  _PathKeyframe _pathMeasureKeyframe;
  //PathMeasure _pathMeasure;

  _PathKeyframeAnimation(Scene<PointF> scene) : super(scene);

  @override
  PointF getValue(Keyframe<PointF> keyframe, double keyframeProgress) {
    _PathKeyframe _pathKeyframe = keyframe;

    if(_pathKeyframe._path == null) {
      return keyframe.startValue;
    }


    //TODO: No PathMeasure in flutter sdk :(
    if(_pathKeyframe != _pathKeyframe) {
      // _pathMeasure = new PathMeasure(_pathKeyframe._path, false);
      _pathMeasureKeyframe = keyframe;
    }

    //pathMeasure.getPosTan(keyframeProgress * pathMeasure.length, pos, null);
    //point.set(pos[0],pos[1]);
    //return point;
    return const PointF(0.0, 0.0);
  }
}


class _PathKeyframe extends Keyframe<PointF> {

  Path _path;

  Path get path => _path;

  _PathKeyframe(double startFrame, double endFrame, int durationFrames,
      PointF startValue, PointF endValue)
      : super(startFrame, endFrame, durationFrames, startValue, endValue);

  _PathKeyframe.fromMap(dynamic map, double scale) {
    Keyframe<PointF> keyframe = new Keyframe.fromMap(map, Parsers.pointFParser, scale);
    PointF cp1 = Parsers.pointFParser.parse(map['ti'], scale);
    PointF cp2 = Parsers.pointFParser.parse(map['to'], scale);

    bool equals = keyframe.endValue != null && keyframe.startValue != null &&
                  keyframe.endValue.x == keyframe.endValue.y;
    if(!equals) {
      _path = new Path(keyframe.startValue, keyframe.startValue, cp1, cp2);
    }
  }

}
