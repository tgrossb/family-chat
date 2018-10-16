import 'package:flutter/material.dart';

final ThemeData splashTheme = new ThemeData(
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
      display4: TextStyle(color: Colors.black),
      headline: TextStyle(color: Colors.black),

      // Used for the welcome on new user screen
      display3: TextStyle(color: Colors.white),

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

      // Found at https://github.com/flutter/flutter/blob/master/packages/flutter/lib/src/material/input_decorator.dart line 1849
      // Explicitly defined instead of using defaults so that it can be used in calculations easily
      contentPadding: EdgeInsets.fromLTRB(12.0, 24.0, 12.0, 16.0)
    ),

    errorColor: Color(0xff8c0808),

    dialogBackgroundColor: Color(0xffeeeeee)
);

final appTheme = ThemeData(
  primaryColor: splashTheme.accentColor,
  accentColor: splashTheme.primaryColor,

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
    subhead: TextStyle(color: Colors.black),
    title: TextStyle(color: Colors.black),
  )
);