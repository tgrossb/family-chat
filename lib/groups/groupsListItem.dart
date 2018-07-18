import 'package:flutter/material.dart';
import "package:intl/intl.dart" as intl;
import '../chatScreen.dart';
import 'dart:math' as math;

class EaseIn extends Tween<Offset> {
  EaseIn(): super(begin: Offset(1.0, 0.0), end: Offset(0.0, 0.0));

  double map(double x, double a, double b, double c, double d){
    return (x-a)*(d-c)/(b-a)+c;
  }

  double transform(double t){
    // My one
//    t = map(t, 0.0, 1.0, 0.0, 3.5);
//    double x = 1 - math.pow(math.e, -.5*t*t) * math.cos(t*t);

    double x = 1 - math.pow(math.e, -5*t*t) * math.cos(10*t*t);

    return x;
  }

  Offset lerp(double t){
    return Offset(1.0 - transform(t), 0.0);
  }
}

class GroupsListItem extends StatelessWidget {
  static DateTime parseTime(String rawTime){
    if (rawTime == "0")
      return new DateTime(0);
    return DateTime.parse(rawTime.replaceAll(ChatScreenState.dotReplace, "."));
  }

  static String formatTime(String rawTime){
    if (rawTime == "0")
      return "";
    DateTime dt = parseTime(rawTime);
    var format = new intl.DateFormat("hh:mm a, EEE, MMM d, yyyy");
    return format.format(dt.toLocal());
  }

  GroupsListItem({this.rawTime, this.name, this.startGroup, this.deleteGroup, this.animationController}):
        utcTime = GroupsListItem.parseTime(rawTime), time = GroupsListItem.formatTime(rawTime);
  final Function startGroup, deleteGroup;
  final String time, name, rawTime;
  final AnimationController animationController;
  final DateTime utcTime;

  @override
  Widget build(BuildContext context) {
    return animationController == null ? normalMessage(context) : new SlideTransition(
        position: new EaseIn().animate(animationController),
        child: normalMessage(context)
    );
  }

  Widget normalMessage(BuildContext context){
    return GestureDetector(
      onTap: () => startGroup(context, name),
      child: new Container(
        color: Colors.transparent,
        alignment: Alignment(1.0, 0.0),
        margin: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 8.0),
        child: new Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            profilePic(context, true),
            message(context, CrossAxisAlignment.start),

            new IconButton(
              icon: new Icon(Icons.delete),
              onPressed: () => deleteGroup(context, this),
            ),
          ]
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

  bool isAfter(GroupsListItem other){
    return utcTime.isAfter(other.utcTime);
  }

  int compareTo(GroupsListItem other){
    return utcTime.difference(other.utcTime).inMicroseconds;
  }

  @override
  operator ==(dynamic other){
    if (identical(this, other))
      return true;
    if (other.runtimeType != String && other.runtimeType != GroupsListItem)
      return false;

    if (other.runtimeType == String)
      return name == other;

    final GroupsListItem otherItem = other;
    return name == otherItem.name;
  }

  @override
  int get hashCode {
    return name.hashCode;
  }
}