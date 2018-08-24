import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:bodt_chat/splash/splash_page.dart';

final ThemeData iosTheme = new ThemeData(
  primarySwatch: Colors.orange,
  primaryColor: Colors.grey[100],
  primaryColorBrightness: Brightness.light,
);

final ThemeData defaultTheme = new ThemeData(
  primarySwatch: Colors.cyan,
//  accentColor: Colors.orangeAccent[400],
  accentColor: Colors.green,
  primaryTextTheme: TextTheme(display1: new TextStyle(color: Colors.black54)),
//  inputDecorationTheme: ThemeData.dark().inputDecorationTheme,
  brightness: Brightness.dark,
//  textTheme: Typography(platform: defaultTargetPlatform).white,
);

void main() {
  runApp(new BodtChatApp());
}

class BodtChatApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      theme: defaultTargetPlatform == TargetPlatform.iOS ? iosTheme : defaultTheme,
      home: new SplashPage(),
    );
  }
}