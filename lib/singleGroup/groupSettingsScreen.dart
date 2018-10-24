/**
 * This is the screen for an entire group.  This is where the
 * messages of the group are displayed.
 *
 * TODO: Add an events tab style thing to the group screen (big)
 *
 * Group messages are loaded asynchronously, but the first few
 * messages (~10) should be preloaded in the initial loading stage
 * so the user isn't left waiting when the group screen launches.
 *
 * Written by: Theo Grossberndt
 */

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:bodt_chat/singleGroup/groupMessage.dart';
import 'package:bodt_chat/constants.dart';
import 'package:bodt_chat/utils.dart';
import 'package:bodt_chat/dataUtils/dataBundles.dart';
import 'package:bodt_chat/dataUtils/database.dart';
import 'package:bodt_chat/widgetUtils/colorPickerButton.dart';

class GroupSettingsScreen extends StatefulWidget {
  GroupSettingsScreen({@required this.data});
  final GroupData data;

  @override
  State createState() => new GroupSettingsScreenState(data: data);
}

class GroupSettingsScreenState extends State<GroupSettingsScreen> with TickerProviderStateMixin {
  GroupData data;
  Color accentColor;
  Color currentPickerColor;
  var configOptions;

  GroupSettingsScreenState({@required this.data});

  @override
  void initState(){
    accentColor = data.groupThemeData.accentColor;
    currentPickerColor = accentColor;
    configOptions = [];
    super.initState();
  }

  Widget build(BuildContext context){
    return new Scaffold(
        appBar: new AppBar(
          title: new Text(data.name, style: Theme.of(context).primaryTextTheme.title.copyWith(color: Utils.pickTextColor(data.groupThemeData.accentColor))),
          elevation: Theme.of(context).platform == TargetPlatform.iOS ? 0.0 : 4.0,
          backgroundColor: data.groupThemeData.accentColor,
        ),
        body: new ListView(
          children: <Widget>[
            ListTile(
              title: Text("Theme"),
            ),

            Divider(),

            ListTile(
              title: Text("Accent Color"),
              trailing: ColorPickerButton(initialColor: accentColor, onColorConfirmed: (c) => setState(() => accentColor = c)),
            )
          ],
        )
    );
  }



  @override
  void dispose() {
    super.dispose();
  }
}