import 'package:flutter/material.dart';

class MessageData {
  MessageData({this.text, this.name, this.time});
  String text, name;
  DateTime time;
}

class ChatMessage extends StatelessWidget {
  ChatMessage({this.text, this.name, this.myName, this.animationController});
  final String text, name, myName;
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
        mainAxisAlignment: name == myName ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: name == myName ?
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
          child: new Text(name[0], style: theme.primaryTextTheme.body1),
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
            child: new Text(text),
          ),
          new Text(name == myName ? "You" : name, style: Theme.of(context).primaryTextTheme.caption),
        ],
      ),
    );
  }
}