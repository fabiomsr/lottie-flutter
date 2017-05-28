import 'dart:async';
import 'dart:convert';
import 'package:Lotie_Flutter/src/composition.dart';
import 'package:Lotie_Flutter/src/lottie.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;

void main() {
  runApp(new MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'Flutter Demo',
      theme: new ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: new MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _MyHomePageState createState() => new _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;
  LottieComposition _composition;

  void _incrementCounter() {
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
        title: new Text(widget.title),
      ),
      body: new Container(
          child: _composition == null ? new Text("Open file...") : new Lottie(composition: _composition)
      ),
      floatingActionButton: new FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: new Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}

Future<LottieComposition> loadAsset() async {
  return await rootBundle
      .loadString('assets/emoji_shock.json')
      .then((json) => JSON.decode(json))
      .then((map) => new LottieComposition.fromMap(map));
}
