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

class MessageData {
  MessageData({this.text, this.name, this.time}) {
    _nulls = [];
    if (!Utils.textNotEmpty(text))
      _nulls.add("text");
    if (!Utils.textNotEmpty(name))
      _nulls.add("name");
    if (time == null)
      _nulls.add("time");
  }
  String text, name;
  DateTime time;
  List<String> _nulls;

  bool get hasNull => _nulls.length > 0;
  String get getNulls => _nulls.join(", ");

  @override
  bool operator ==(other) {
    MessageData otherData = other;
    return text == otherData.text && name == otherData.name && time.millisecondsSinceEpoch == otherData.time.millisecondsSinceEpoch;
  }

  @override
  // TODO: Don't think this will be used, but could break
  int get hashCode => time.millisecondsSinceEpoch;
}

class GroupMessage extends StatelessWidget {
  GroupMessage({text, name, time, myName, this.animationController}):
      data = new MessageData(text: text, name: name, time: time),
      myMessage = myName == name {
    if (data.hasNull)
      ArgumentError.notNull(data.getNulls);
  }

  GroupMessage.fromData({this.data, myName, this.animationController}):
      myMessage = myName == data.name {
    if (data.hasNull)
      ArgumentError.notNull("data (" + data.getNulls + ")");
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
          child: new Text(data.name[0], style: theme.primaryTextTheme.body1),
          backgroundColor: rightIn ? pcl : ac,
      ),
    );
  }

  Widget message(BuildContext context, CrossAxisAlignment caa){
    return new Expanded(
      child: new Column(
        crossAxisAlignment: caa,
        children: <Widget>[
          new Container(
            margin: const EdgeInsets.only(top: 5.0),
            child: new Text(data.text),
          ),
          new Text(myMessage ? "You" : data.name, style: Theme.of(context).primaryTextTheme.caption),
        ],
      ),
    );
  }
}