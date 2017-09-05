import 'dart:async';
import 'dart:convert';
import 'package:lottie_flutter/src/composition.dart';
import 'package:lottie_flutter/src/lottie.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;

void main() {
  runApp(new DemoApp());
}

class DemoApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'Lottie Demo',
      theme: new ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: new LottieDemo(),
    );
  }
}

class LottieDemo extends StatefulWidget {
  LottieDemo({Key key}) : super(key: key);

  @override
  _LottieDemoState createState() => new _LottieDemoState();
}

class _LottieDemoState extends State<LottieDemo> {
  LottieComposition _composition;

  void _loadButtonPressed() {
    loadAsset().then((composition) {
      setState(() {
      _composition = composition;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text('Lottie Demo'),
      ),
      body: new Container(
          child: _composition == null ? new Text("Click button to load.") : new Lottie(composition: _composition)
      ),
      floatingActionButton: new FloatingActionButton(
        onPressed: _loadButtonPressed,
        tooltip: 'Increment',
        child: new Icon(Icons.add),
      ),
    );
  }
}

Future<LottieComposition> loadAsset() async {
  return await rootBundle
      .loadString('assets/emoji_shock.json')
      .then((json) => JSON.decode(json))
      .then((map) => new LottieComposition.fromMap(map));
}
