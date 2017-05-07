
import 'package:Lotie_Flutter/src/keyframes.dart';
import 'package:Lotie_Flutter/src/painting.dart';

import 'package:Lotie_Flutter/src/transforms.dart';
import 'package:flutter/painting.dart' show Color;


enum LayerType { PreComp, Solid, Image, Null, Shape, Text, Unknown }
enum MatteType { None, Add, Invert, Unknown }

class Layer {

  final int _id;
  final int _parentId;
  final int _solidWidth;
  final int _solidHeight;
  final double _timeStretch;
  final double _startProgress;
  final String _name;
  final String _refId;
  final Color _solidColor;
  final List _shapes;
  final List<Mask> _masks;
  final List<Keyframe<double>> _inOutKeyframes;
  final LayerType _type;
  final MatteType _matteType;
  final AnimatableTransform _transform;

  int get id => _id;

  int get parentId => _parentId;

  int get solidWidth => _solidWidth;

  int get solidHeight => _solidHeight;

  Color get solidColor => _solidColor;

  double get timeStretch => _timeStretch;

  double get startProgress => _startProgress;

  String get name => _name;

  String get refId => _refId;

  List get shapes => _shapes;

  List<Keyframe<double>> get inOutKeyframes => _inOutKeyframes;

  LayerType get type => _type;

  MatteType get matteType => _matteType;

  AnimatableTransform get transform => _transform;


  Layer()
      : _shapes = const [],
        _name = null,
        _id = -1,
        _type = LayerType.PreComp,
        _parentId = -1,
        _refId = null,
        _masks = const [],
        _transform = new AnimatableTransform(),
        _solidWidth = 0,
        _solidHeight = 0,
        _solidColor = const Color(0x0),
        _timeStretch = 0.0,
        _startProgress = 0.0,
        _inOutKeyframes = const [],
        _matteType = MatteType.None;



}

