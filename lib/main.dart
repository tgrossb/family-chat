import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:bodt_chat/splash/splash_page.dart';

final ThemeData iosTheme = new ThemeData(
  primarySwatch: Colors.orange,
  primaryColor: Colors.grey[100],
  primaryColorBrightness: Brightness.light,
);

final ThemeData defaultTheme = new ThemeData(
  primaryColor: Color(0xff413c58),
  accentColor: Color(0xff63a375),

  textTheme: TextTheme(
    body1: TextStyle(color: Colors.black),
    body2: TextStyle(color: Colors.black),
    button: TextStyle(color: Colors.black),
    caption: TextStyle(color: Colors.black),
    display1: TextStyle(color: Colors.black),
    display2: TextStyle(color: Colors.black),
    display3: TextStyle(color: Colors.black),
    display4: TextStyle(color: Colors.black),
    headline: TextStyle(color: Colors.black),

    // Used for the form input text
    subhead: TextStyle(color: Colors.white),

    title: TextStyle(color: Colors.black),
  ),

  primaryTextTheme: TextTheme(
    body1: TextStyle(color: Colors.black),
    body2: TextStyle(color: Colors.black),
    button: TextStyle(color: Colors.black),
    caption: TextStyle(color: Colors.black),
    display1: TextStyle(color: Colors.black),
    display2: TextStyle(color: Colors.black),
    display3: TextStyle(color: Colors.black),
    display4: TextStyle(color: Colors.black),
    headline: TextStyle(color: Colors.black),

    // Used for the sign in button
    title: TextStyle(color: Colors.white),
    subhead: TextStyle(color: Colors.white),
  ),

  buttonTheme: ButtonThemeData(
    textTheme: ButtonTextTheme.primary
  ),

  accentTextTheme: TextTheme(
    body1: TextStyle(color: Colors.black),
    body2: TextStyle(color: Colors.black),
    button: TextStyle(color: Colors.black),
    caption: TextStyle(color: Colors.black),
    display1: TextStyle(color: Colors.black),
    display2: TextStyle(color: Colors.black),
    display3: TextStyle(color: Colors.black),
    display4: TextStyle(color: Colors.black),
    headline: TextStyle(color: Colors.black),
    subhead: TextStyle(color: Colors.black),
    title: TextStyle(color: Colors.black),
  ),

  // Used for the form
  inputDecorationTheme: InputDecorationTheme(
    labelStyle: TextStyle(color: Colors.white70),
    hintStyle: TextStyle(color: Colors.white70),
    errorStyle: TextStyle(color: Color(0xff8c0808)),
    filled: true,
    fillColor: Color(0x11000000),
//    prefixStyle: TextStyle(color: Colors.white)
  ),

  errorColor: Color(0xff8c0808),

//  primaryIconTheme: IconThemeData(color: Colors.white70),
//  brightness: Brightness.light,
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