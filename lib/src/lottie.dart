import 'package:Lotie_Flutter/src/composition.dart';
import 'package:Lotie_Flutter/src/drawing/drawing_layers.dart';
import 'package:Lotie_Flutter/src/layers.dart';
import 'package:Lotie_Flutter/src/mathutils.dart';
import 'package:flutter/widgets.dart';
import 'package:meta/meta.dart';

class Lottie extends StatefulWidget {
  final LottieComposition _composition;

  Lottie({Key key, @required LottieComposition composition})
      : _composition = composition,
        super(key: key);

  @override
  _LottieState createState() => new _LottieState(_composition);
}

class _LottieState extends State<Lottie> with SingleTickerProviderStateMixin {
  final LottieComposition _composition;
  CompositionLayer _compositionLayer;
  AnimationController _animation;

  _LottieState(this._composition) {
    final size = _composition.bounds.size;
    _compositionLayer = new CompositionLayer(
        _composition, new Layer.empty(size.width, size.height), () => {}, 1.0);
  }

  @override
  void initState() {
    super.initState();

    _animation = new AnimationController(
      duration: new Duration(milliseconds: _composition.duration),
      lowerBound: 0.0,
      upperBound: 1.0,
      vsync: this,
    )..repeat();

    _animation.addListener(_handleChange);
  }

  void _handleChange() {
    print("Progress: ${_animation.value}");
    setState(() {
      _compositionLayer.progress = _animation.value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return new CustomPaint(
        painter: new LottiePainter(_compositionLayer), size: const Size(200.0, 200.0));
  }

  @override
  void dispose() {
    _animation.removeListener(_handleChange);
    _animation.dispose();
    super.dispose();
  }
}

class LottiePainter extends CustomPainter {
  final CompositionLayer _compositionLayer;
  final double _scale;
  final int _alpha;

  LottiePainter(this._compositionLayer, { double scale: 1.0, int alpha: 255 } )
    : _scale = scale,
      _alpha = alpha;

  @override
  void paint(Canvas canvas, Size size) {
    final matrix = new Matrix4.identity();
    leftScale(matrix, _scale, _scale);

    _compositionLayer.draw(canvas, size, matrix, _alpha);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
