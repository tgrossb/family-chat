import 'dart:math' as math;
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:bodt_chat/dataUtils/dataBundles.dart';
import 'package:intl/intl.dart' as intl;
import 'package:bodt_chat/constants.dart' as Constants;

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

class GroupsListItem extends StatefulWidget {
  GroupsListItem.fromData({GlobalKey key, @required this.data, @required this.controller, this.onClick, this.onDelete}):
        super(key: key ?? GlobalKey());

  final GroupData data;
  final AnimationController controller;
  final Function onClick, onDelete;

  @override
  State createState() => new GroupsListItemState(onClick: onClick, onDelete: onDelete, controller: controller, data: data);

  void startAnimation({double from = 0.0, int msOffset = 0}) async {
    ((super.key as GlobalKey).currentState as GroupsListItemState).startAnimation(from: from, msOffset: msOffset);
  }

  void disable() async {
    ((super.key as GlobalKey).currentState as GroupsListItemState).disable();
  }

  void enable() async {
    ((super.key as GlobalKey).currentState as GroupsListItemState).enable();
  }

  void setData(GroupData data) async {
    ((super.key as GlobalKey).currentState as GroupsListItemState).setData(data);
  }
}

class GroupsListItemState extends State<GroupsListItem> {
  Function onClick, onDelete;
  GroupData data;
  AnimationController controller;
  bool enabled = true;

  GroupsListItemState({@required this.onClick, @required this.onDelete, @required this.data, @required this.controller});

  @override
  Widget build(BuildContext context) {
    return controller == null ? normalMessage(context) : new SlideTransition(
        position: new EaseIn().animate(controller),
        child: normalMessage(context)
    );
  }

  Widget normalMessage(BuildContext context){
    return GestureDetector(
      onTap: enabled ? () => onClick(context, data.uid) : null,
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
              onPressed: enabled ? () => onDelete(context, data.uid) : null,
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

    return new Container(
      margin: rightIn ? right : left,
      child: new CircleAvatar(
        child: new Text(data.name[0], style: theme.primaryTextTheme.headline),
        backgroundColor: data.groupThemeData.groupColor,
      ),
    );
  }

  Widget message(BuildContext context, CrossAxisAlignment caa){
    var format;
    DateTime now = DateTime.now();
    DateTime lastLocalTime = data.utcTime.toLocal();
    DateTime midnight = DateTime(now.year, now.month, now.day);
    DateTime sixDaysAgo = now.subtract(Duration(days: 6));
    DateTime jan1 = DateTime(now.year);

    // Use the time if the last message occurred today
    if (lastLocalTime.isAfter(midnight))
      format = intl.DateFormat("h:mm a");
    // Use the day if the last message occurred within the past six days
    else if (lastLocalTime.isAfter(sixDaysAgo))
      format = intl.DateFormat("EEE");
    // Use the month and day of month if the last message occurred within this year
    else if (lastLocalTime.isAfter(jan1))
      format = intl.DateFormat("MMM d");
    // Use the full month day, year if else
    else
      format = Constants.kDAY_MONTH_YEAR_FORMAT;

    String dateString = format.format(lastLocalTime);

    return new Expanded(
      child: new Column(
        crossAxisAlignment: caa,
        children: <Widget>[
          new Container(
            margin: const EdgeInsets.only(top: 5.0),
            child: new Text(data.name, style: Theme.of(context).primaryTextTheme.title.copyWith(fontWeight: FontWeight.normal)),
          ),
          new Text(dateString, style: Theme.of(context).primaryTextTheme.body2.copyWith(fontWeight: FontWeight.normal)),
        ],
      ),
    );
  }

  void startAnimation({double from = 0.0, int msOffset = 0}) async {
    controller.reset();
    controller.stop(canceled: false);
    Future.delayed(Duration(milliseconds: msOffset), () => controller.forward(from: from));
  }

  void disable() async {
    setState(() {
      enabled = false;
    });
  }

  void enable() async {
    setState(() {
      enabled = true;
    });
  }

  void setData(GroupData data) async {
    setState((){
      this.data = data;
    });
  }

  bool isAfter(GroupsListItemState other){
    return data.utcTime.isAfter(other.data.utcTime);
  }

  int compareTo(GroupsListItemState other){
    return data.utcTime.difference(other.data.utcTime).inMicroseconds;
  }

  @override
  operator ==(dynamic other){
    if (identical(this, other))
      return true;
    if (other.runtimeType != String && other.runtimeType != GroupsListItem)
      return false;

    if (other.runtimeType == String)
      return data.uid == other;

    final GroupsListItem otherItem = other;
    return data.uid == otherItem.data.uid;
  }

  @override
  int get hashCode {
    return data.uid.hashCode;
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}