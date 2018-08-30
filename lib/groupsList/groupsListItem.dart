import 'dart:math' as math;
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:bodt_chat/utils.dart';
import 'package:bodt_chat/dataUtils/dataBundles.dart';

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
  static GroupsListItemState of(BuildContext context) => context.ancestorStateOfType(const TypeMatcher<GroupsListItemState>());

  GroupsListItem({this.key, @required DateTime utcTime, @required String name,
                    @required Function start, @required Function delete, @required AnimationController animationController,
                    List<MessageData> firstMessages = const []}):
        data = new GroupData(utcTime: utcTime, name: name, firstMessages: firstMessages),
        impData = new GroupImplementationData(start: start, delete: delete, animationController: animationController),
        super(key: key);

  GroupsListItem.fromData({this.key, @required this.data, @required this.impData}):
        super(key: key);

  final GlobalKey<GroupsListItemState> key;
  final GroupData data;
  final GroupImplementationData impData;

  @override
  State createState() => new GroupsListItemState.fromData(data: data, impData: impData);

  void startAnimation({double from = 0.0, int msOffset = 0}) async {
    impData.animationController.reset();
    impData.animationController.stop(canceled: false);
    Future.delayed(Duration(milliseconds: msOffset), () => impData.animationController.forward(from: from));
  }
}

class GroupsListItemState extends State<GroupsListItem> {
  GroupsListItemState.fromData({@required this.data, @required this.impData}){
    // TODO: Check for completely not null data
  }

  GroupData data;
  GroupImplementationData impData;

  @override
  Widget build(BuildContext context) {
    return impData.animationController == null ? normalMessage(context) : new SlideTransition(
        position: new EaseIn().animate(impData.animationController),
        child: normalMessage(context)
    );
  }

  Widget normalMessage(BuildContext context){
    return GestureDetector(
      onTap: () => impData.start(context, data.name),
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
              onPressed: () => impData.delete(context, this),
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
        child: new Text(data.name[0], style: theme.primaryTextTheme.headline),
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
            child: new Text(data.name, style: Theme.of(context).primaryTextTheme.title.copyWith(fontWeight: FontWeight.normal)),
          ),
          new Text(Utils.timeToReadableString(data.utcTime), style: Theme.of(context).primaryTextTheme.body2.copyWith(fontWeight: FontWeight.normal)),
        ],
      ),
    );
  }

  void startAnimation({double from = 0.0}){
    impData.animationController.forward(from: from);
  }

  /*
  void update({String newRawTime, String newName, bool reanimate = true}){
    if (newRawTime != null || newName != null) {
      setState(() {
        if (newRawTime != null){
          utcTime = Utils.parseTime(newRawTime);
          time = Utils.formatTime(newRawTime);
        }

        if (newName != null)
          name = newName;

        if (reanimate)
          animationController.forward(from: 0.0);
      });
    }
  }

  void updateFromData({@required GroupData data, @required GroupImplementationData impData}){
    if (impData.start == null && impData.delete == null && data.time == null && data.rawTime == null &&
        data.name == null && impData.animationController == null && data.rawTime == null)
      return;
    setState(() {
      if (impData.start != null) start = impData.start;
      if (impData.delete != null) delete = impData.delete;
      if (data.name != null) name = data.name;
      if (impData.animationController != null) animationController = impData.animationController;
      if (data.utcTime != null && data.time != null){
        utcTime = data.utcTime;
        time = data.time;
      } else if (data.rawTime != null){
        utcTime = Utils.parseTime(data.rawTime);
        time = Utils.formatTime(data.rawTime);
      }
    });
  }
  */

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
      return data.name == other;

    final GroupsListItem otherItem = other;
    return data.name == otherItem.data.name;
  }

  @override
  int get hashCode {
    return data.name.hashCode;
  }
}