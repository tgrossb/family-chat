/**
 * This is a simple message widget.
 *
 * A simple message contains the message, the name of the sender,
 * and the date and time at which it was sent.
 *
 * The data of a GroupMessage can be extracted as a MessageData object.
 *
 * It is preferable to create a GroupMessage from its MessageData using the
 * fromData constructor because a GroupMessage object uses a MessageData object
 * internally either way.
 *
 * Written by: Theo Grossberndt
 */

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:bodt_chat/utils.dart';
import 'package:bodt_chat/dataUtils/dataBundles.dart';
import 'package:bodt_chat/dataUtils/database.dart';
import 'package:bodt_chat/widgetUtils/maxHeight.dart';

class GroupMessage extends StatefulWidget {
  GroupMessage.fromData({GlobalKey key, @required this.data, @required this.animationController, @required this.themeData}):
      super(key: key ?? new GlobalKey());

  final MessageData data;
  final AnimationController animationController;
  final GroupThemeData themeData;

  @override
  State<StatefulWidget> createState() => GroupMessageState(data: data, controller: animationController, themeData: themeData);

  void setThemeData(GroupThemeData newThemeData) async {
    if ((super.key as GlobalKey).currentState == null)
      themeData.copyFrom(newThemeData);

    else
      ((super.key as GlobalKey).currentState as GroupMessageState).setThemeData(newThemeData);
  }
}

class GroupMessageState extends State<GroupMessage> {
  bool myMessage;
  MessageData data;
  AnimationController controller;
  GroupThemeData themeData;
  Timer timer;
  String dateTimeString;

  GroupMessageState({@required this.data, @required this.controller, @required this.themeData});

  @override
  void initState() {
    myMessage = data.senderUid == Database.me.uid;

    // Set up a reoccurring timer to update the time strings each minute
    timer = Timer.periodic(Duration(minutes: 1), (t) => setState((){
      dateTimeString = Utils.timeToReadableString(data.utcTime);
    }));
    dateTimeString = Utils.timeToReadableString(data.utcTime);

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return controller == null ? normalMessage(context) : new SizeTransition(
      sizeFactor: new CurvedAnimation(parent: controller, curve: Curves.easeOut),
      axisAlignment: 0.0,

      child: normalMessage(context)
    );
  }

  Widget normalMessage(BuildContext context){
    ThemeData theme = Theme.of(context);

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.0),
      child: MaxHeight(
        mainAxisAlignment: myMessage ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: myMessage ? <Widget>[
          message(context, CrossAxisAlignment.end, theme),
          profilePic(context, theme, EdgeInsets.only(left: 16.0, right: 8.0))
        ] : <Widget>[
          profilePic(context, theme, EdgeInsets.only(left: 8.0, right: 16.0)),
          message(context, CrossAxisAlignment.start, theme)
        ],
      ),
    );
  }

  Widget profilePic(BuildContext context, ThemeData theme, EdgeInsets padding){
    Color bubbleColor;
    if (myMessage)
      bubbleColor = theme.primaryColor;
    else if (data.senderUid == "System")
      bubbleColor = themeData.accentColor;
    else
      bubbleColor = Utils.mixRandomColor(Colors.white);

    return Container(
      padding: padding,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(
            myMessage ? "You" : data.senderUid,
            style: theme.primaryTextTheme.caption,
            textAlign: myMessage ? TextAlign.end : TextAlign.left
          ),
          CircleAvatar(
            child: Text(data.senderUid[0], style: theme.primaryTextTheme.body1.copyWith(color: Utils.pickTextColor(bubbleColor))),
            backgroundColor: bubbleColor,
          ),
        ],
      ),
    );
  }

  Widget message(BuildContext context, CrossAxisAlignment caa, ThemeData theme){
    return new Expanded(
      child: new Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: caa,
        children: <Widget>[
          new Container(
            margin: const EdgeInsets.only(top: 4.0, bottom: 4.0),
            child: new Text(data.text, style: theme.primaryTextTheme.body2),
          ),
          new Text(dateTimeString, style: theme.primaryTextTheme.caption),
        ],
      ),
    );
  }

  void setThemeData(GroupThemeData newThemeData){
    setState(() {
      themeData = newThemeData;
    });
  }

  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }
}