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

import 'package:flutter/material.dart';
import 'package:bodt_chat/utils.dart';
import 'package:bodt_chat/dataUtils/dataBundles.dart';
import 'package:bodt_chat/dataUtils/database.dart';

class GroupMessage extends StatelessWidget {
  GroupMessage.fromData({this.data, this.animationController}):
      this.myMessage = (data.senderUid == Database.me.uid) {
    if (this.data.hasEmpty)
      throw ArgumentError.notNull(this.data.stringEmpties);
  }

  final bool myMessage;
  final MessageData data;
  final AnimationController animationController;

  @override
  Widget build(BuildContext context) {
    return animationController == null ? normalMessage(context) : new SizeTransition(
      sizeFactor: new CurvedAnimation(parent: animationController, curve: Curves.easeOut),
      axisAlignment: 0.0,

      child: normalMessage(context)
    );
  }

  Widget normalMessage(BuildContext context){
    return new Container(
      alignment: Alignment(1.0, 0.0),
      margin: const EdgeInsets.symmetric(vertical: 10.0),
      child: new Row(
        mainAxisAlignment: myMessage ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: myMessage ?
            <Widget>[message(context, CrossAxisAlignment.end), profilePic(context, false)] :
            <Widget>[profilePic(context, true), message(context, CrossAxisAlignment.start)]
      ),
    );
  }

  Widget profilePic(BuildContext context, bool rightIn){
    EdgeInsets right = const EdgeInsets.only(right: 16.0);
    EdgeInsets left = const EdgeInsets.only(left: 16.0);
    ThemeData theme = Theme.of(context);

    Color pcl = theme.primaryColorLight;
    Color ac = theme.accentColor;

    return new Container(
      margin: rightIn ? right : left,
      child: new CircleAvatar(
          child: new Text(data.senderUid[0], style: theme.primaryTextTheme.body1),
          backgroundColor: rightIn ? pcl : ac,
      ),
    );
  }

  Widget message(BuildContext context, CrossAxisAlignment caa){
    return new Expanded(
      child: new Column(
        crossAxisAlignment: caa,
        children: <Widget>[
          new Text(myMessage ? "You" : data.senderUid, style: Theme.of(context).primaryTextTheme.caption),
          new Container(
            margin: const EdgeInsets.only(top: 5.0),
            child: new Text(data.text),
          ),
          // TODO: Add string time parameter to MessageData to prevent formatting things that had to be parsed
          new Text(Utils.timeToFormedString(data.utcTime), style: Theme.of(context).primaryTextTheme.caption),
        ],
      ),
    );
  }
}