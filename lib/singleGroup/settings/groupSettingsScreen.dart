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
import 'package:bodt_chat/singleGroup/settings/colorsConfigs.dart';

class GroupSettingsScreen extends StatefulWidget {
  GroupSettingsScreen({@required this.data});
  final GroupData data;

  @override
  State createState() => new GroupSettingsScreenState(data: data);
}

class ConfigOption {
  static const int COLOR_PICKER = 0;
  int trailingType;
  String name;
  Function onChange;
  Function onReset;

  ConfigOption({this.trailingType, this.name, this.onChange, this.onReset});
}

class GroupSettingsScreenState extends State<GroupSettingsScreen> {
  GroupData data;
  Color accentColor, backgroundColor;
  List<ConfigOption> options;

  GroupSettingsScreenState({@required this.data});

  @override
  void initState(){
    setConfigsToDefaults();

    options = [
      ConfigOption(trailingType: 0, name: "Accent Color", onChange: (c) => setState(() => accentColor = c), onReset: (){}),
      ConfigOption(trailingType: 0, name: "Background Color", onChange: (c) => setState(() => backgroundColor = c), onReset: (){}),
    ];

    super.initState();
  }

  Widget build(BuildContext context){
    return new Scaffold(
        appBar: new AppBar(
          title: new Text(
              data.name,
              style: Theme.of(context).primaryTextTheme.title.copyWith(color: Utils.pickTextColor(data.groupThemeData.accentColor))
          ),

          elevation: Theme.of(context).platform == TargetPlatform.iOS ? 0.0 : 4.0,
          backgroundColor: data.groupThemeData.accentColor,
        ),

        body: ColorsConfig(themeData: data.groupThemeData),

        bottomNavigationBar: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            FlatButton(
              child: Text("Reset"),
              onPressed: () => setConfigsToDefaults(),
              textColor: Colors.redAccent,
            ),
            FlatButton(
              child: Text("Confirm"),
              onPressed: () => finalizeConfigs(),
            )
          ],
        ),
    );
  }

  void finalizeConfigs() async {
    data.groupThemeData.accentColor = accentColor;
    data.groupThemeData.backgroundColor = backgroundColor;

    bool successful = await DatabaseWriter.setGroupTheme(groupUid: data.uid, themeData: data.groupThemeData);

    if (successful)
      Navigator.of(context).pop();
  }

  void setConfigsToDefaults() {
    setState((){
      accentColor = data.groupThemeData.accentColor;
      backgroundColor = data.groupThemeData.backgroundColor;
    });
    print("Finished resetting configs");
  }

  @override
  void dispose() {
    super.dispose();
  }
}