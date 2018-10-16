import 'package:flutter/material.dart';
import 'package:dynamic_theme/dynamic_theme.dart';
import 'package:bodt_chat/splash/splashPage.dart';
import 'package:bodt_chat/themes/defaultTheme.dart' as DefaultTheme;


void main() {
  runApp(new BodtChatApp());
}

class BodtChatApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return DynamicTheme(
      data: (brightness) => DefaultTheme.splashTheme,
      themedWidgetBuilder: (context, theme) => MaterialApp(
        theme: theme,
//      initialRoute: "/",
//      routes: {
//        "/": (context) => SplashPage()
//      },
        home: new SplashPage(),
      ),
    );
  }
}