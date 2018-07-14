import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'chatScreen.dart';

final ThemeData iosTheme = new ThemeData(
  primarySwatch: Colors.orange,
  primaryColor: Colors.grey[100],
  primaryColorBrightness: Brightness.light,
);

final ThemeData defaultTheme = new ThemeData(
  primarySwatch: Colors.purple,
  accentColor: Colors.orangeAccent[400],
);

void main() {
  runApp(new BodtChatApp());
}

class BodtChatApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: "Bodt Chat",
      theme: defaultTargetPlatform == TargetPlatform.iOS ? iosTheme : defaultTheme,
      home: new ChatScreen(),
    );
  }
}