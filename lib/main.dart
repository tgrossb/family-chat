import 'package:flutter/material.dart';
import 'package:hermes/splash/splash.dart';
import 'package:hermes/consts.dart';

void main() => runApp(Hermes());

class Hermes extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Hermes',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primaryColor: Consts.GREEN,
        inputDecorationTheme: InputDecorationTheme(
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: Consts.GREEN
            )
          ),

          border: OutlineInputBorder(),

          labelStyle: TextStyle(color: Consts.GREEN.withOpacity(0.5)),
        ),

        buttonTheme: ButtonThemeData(
          buttonColor: Consts.GREEN,
          textTheme: ButtonTextTheme.primary
        ),

        cursorColor: Consts.GREEN,
        textSelectionColor: Consts.BLUE,
        textSelectionHandleColor: Consts.BLUE
      ),
      home: Splash(),
    );
  }
}