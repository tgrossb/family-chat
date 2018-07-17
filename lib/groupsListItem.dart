import 'package:flutter/material.dart';
import "package:intl/intl.dart";
import 'chatScreen.dart';

class GroupsListItem extends StatelessWidget {
  static DateTime parseTime(String rawTime){
    if (rawTime == "0")
      return new DateTime(0);
    return DateTime.parse(rawTime.replaceAll(ChatScreenState.dotReplace, "."));
  }

  static String formatTime(String rawTime){
    if (rawTime == "0")
      return "";
    DateTime dt = GroupsListItem.parseTime(rawTime);
    var format = new DateFormat("hh:mm a, EEE, MMM d, yyyy");
    return format.format(dt.toLocal());
  }

  GroupsListItem({this.time, this.rawTime, this.name, this.startChat, this.animationController});
  final Function startChat;
  final String time, name, rawTime;
  final AnimationController animationController;
  DateTime parsedTime;

  @override
  Widget build(BuildContext context) {
    return animationController == null ? normalMessage(context) : new SizeTransition(
        sizeFactor: new CurvedAnimation(parent: animationController, curve: Curves.easeOut),
        axisAlignment: 1.0,
        axis: Axis.horizontal,

        child: normalMessage(context)
    );
  }

  Widget normalMessage(BuildContext context){
    return  GestureDetector(
      onTap: () => startChat(context, name),
      child: new Container(
        color: Colors.transparent,
        alignment: Alignment(1.0, 0.0),
        margin: const EdgeInsets.symmetric(vertical: 10.0),
        child: new Row(
            mainAxisAlignment:  MainAxisAlignment.start,
            children: <Widget>[profilePic(context, true), message(context, CrossAxisAlignment.start)]
        ),
      )
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
        child: new Text(name[0], style: theme.primaryTextTheme.headline),
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
            child: new Text(name, style: Theme.of(context).primaryTextTheme.title.copyWith(fontWeight: FontWeight.normal)),
          ),
          new Text(time, style: Theme.of(context).primaryTextTheme.body2.copyWith(fontWeight: FontWeight.normal)),
        ],
      ),
    );
  }

  bool after(GroupsListItem other){
    if (parsedTime == null)
      parsedTime = GroupsListItem.parseTime(rawTime);
    if (other.parsedTime == null)
      other.parsedTime = GroupsListItem.parseTime(other.rawTime);
    return parsedTime.isAfter(other.parsedTime);
  }
}