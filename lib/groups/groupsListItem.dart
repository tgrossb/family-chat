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

class GroupData {
  GroupData({this.rawTime, this.time, this.utcTime, this.name, this.start, this.delete, this.animationController});
  Function start, delete;
  String rawTime, name, time;
  AnimationController animationController;
  DateTime utcTime;
}

class GroupsListItem extends StatefulWidget {
  static GroupsListItemState of(BuildContext context) => context.ancestorStateOfType(const TypeMatcher<GroupsListItemState>());

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

  GroupsListItem({this.key, this.rawTime, this.name, this.start, this.delete, this.animationController}): super(key: key);
  final GlobalKey<GroupsListItemState> key;
  final String rawTime, name;
  final Function start, delete;
  final AnimationController animationController;

  @override
  State createState(){
    GroupsListItemState itemState = new GroupsListItemState(
        utcTime: parseTime(rawTime),
        time: formatTime(rawTime),
        name: name,
        start: start,
        delete: delete,
        animationController: animationController
    );
//    key.currentState = itemState;
    return itemState;
  }
}

class GroupsListItemState extends State<GroupsListItem> {
  GroupsListItemState({this.utcTime, this.time, this.name, this.start, this.delete, this.animationController});
  Function start, delete;
  String time, name;
  AnimationController animationController;
  DateTime utcTime;

  @override
  Widget build(BuildContext context) {
    return animationController == null ? normalMessage(context) : new SlideTransition(
        position: new EaseIn().animate(animationController),
        child: normalMessage(context)
    );
  }

  Widget normalMessage(BuildContext context){
    return GestureDetector(
      onTap: () => start(context, name),
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
              onPressed: () => delete(context, this),
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

  void update({String newRawTime, String newName, bool reanimate = true}){
    if (newRawTime != null || newName != null) {
      setState(() {
        if (newRawTime != null){
          utcTime = GroupsListItem.parseTime(newRawTime);
          time = GroupsListItem.formatTime(newRawTime);
        }

        if (newName != null)
          name = newName;

        if (reanimate)
          animationController.forward(from: 0.0);
      });
    }
  }

  void updateFromData({@required GroupData data}){
    if (data.start == null && data.delete == null && data.time == null && data.rawTime == null &&
        data.name == null && data.animationController == null && data.rawTime == null)
      return;
    setState(() {
      if (data.start != null) start = data.start;
      if (data.delete != null) delete = data.delete;
      if (data.name != null) name = data.name;
      if (data.animationController != null) animationController = data.animationController;
      if (data.utcTime != null && data.time != null){
        utcTime = data.utcTime;
        time = data.time;
      } else if (data.rawTime != null){
        utcTime = GroupsListItem.parseTime(data.rawTime);
        time = GroupsListItem.formatTime(data.rawTime);
      }
    });
  }

  bool isAfter(GroupsListItemState other){
    return utcTime.isAfter(other.utcTime);
  }

  int compareTo(GroupsListItemState other){
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