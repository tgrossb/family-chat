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
import 'package:bodt_chat/widgetUtils/animatedIconSwitch.dart';

class GroupSettingsScreen extends StatefulWidget {
  GroupSettingsScreen({@required this.data});
  final GroupData data;

  @override
  State createState() => new GroupSettingsScreenState(data: data);
}

class GroupSettingsScreenState extends State<GroupSettingsScreen> with TickerProviderStateMixin {
  GroupData data;
  Color accentColor, backgroundColor;

  GroupSettingsScreenState({@required this.data});

  @override
  void initState(){
    setConfigsToDefaults();
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
              title: Text("Theme", style: Theme.of(context).primaryTextTheme.title),
              leading: AnimatedIconSwitch(
                onPressed: (){},
                unselected: Icons.arrow_drop_down,
                selected: Icons.arrow_drop_up
              ),
            ),

            Divider(),

            ListTile(
              title: Text("Accent Color"),
              trailing: ColorPickerButton(
                initialColor: accentColor,
                onColorConfirmed: (c) => setState(() => accentColor = c)
              ),
            ),

            Divider(),

            ListTile(
              title: Text("Background Color"),
              trailing: ColorPickerButton(
                initialColor: backgroundColor,
                onColorConfirmed: (c) => setState(() => backgroundColor = c),
                borderWidth: 2.5,
                borderColor: Utils.pickTextColor(backgroundColor),
              ),
            ),

            Divider(),
          ],
        ),
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