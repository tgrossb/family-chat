import 'dart:math' as math;
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:bodt_chat/dataUtils/dataBundles.dart';
import 'package:bodt_chat/utils.dart';
import 'package:bodt_chat/widgetUtils/animatedIconSwitch.dart';
import 'package:bodt_chat/widgetUtils/maxHeight.dart';

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

  Future<void> startAnimation({double from = 0.0, int msOffset = 0}) async {
    while ((super.key as GlobalKey).currentState == null){}
    ((super.key as GlobalKey).currentState as GroupsListItemState).startAnimation(from: from, msOffset: msOffset);
  }

  void disable() async {
    while ((super.key as GlobalKey).currentState == null){}
    ((super.key as GlobalKey).currentState as GroupsListItemState).disable();
  }

  void enable() async {
    while ((super.key as GlobalKey).currentState == null){}
    ((super.key as GlobalKey).currentState as GroupsListItemState).enable();
  }

  void setData(GroupData data) async {
    while ((super.key as GlobalKey).currentState == null){}
    ((super.key as GlobalKey).currentState as GroupsListItemState).setData(data);
  }
}

class GroupsListItemState extends State<GroupsListItem> {
  Function onClick, onDelete;
  GroupData data;
  AnimationController controller;
  bool enabled = true;
  Timer timer;
  String dateTimeString;

  GroupsListItemState({@required this.onClick, @required this.onDelete, @required this.data, @required this.controller});

  @override
  void initState() {
    // Set up a reoccurring timer to update the time on the messages each minute
    timer = Timer.periodic(Duration(minutes: 1), (t) => setState((){
      dateTimeString = Utils.timeToReadableString(data.utcTime, short: true);
    }));
    dateTimeString = Utils.timeToReadableString(data.utcTime, short: true);

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return controller == null ? normalMessage(context) :
      SlideTransition(
        position: new EaseIn().animate(controller),
        child: normalMessage(context)
      );
  }

  Widget normalMessage(BuildContext context){
    ThemeData theme = Theme.of(context);
    return MaxHeight(
      children: <Widget>[
        Expanded(
          child: GestureDetector(
            onTap: () => onClick(context, data),
            child: MaxHeight(
              children: <Widget>[
                buildGroupIcon(context, theme),
                buildNameAndLastMsg(context, theme)
              ],
            ),
          ),
        ),

        buildTimeAndBell(context, theme)
      ],
    );
  }

  Widget buildGroupIcon(BuildContext context, ThemeData theme){
    return Container(
      color: Colors.transparent,
      child: FittedBox(
        fit: BoxFit.contain,
        child: CircleAvatar(
          child: Text(data.name[0], style: theme.primaryTextTheme.headline),
          backgroundColor: data.groupThemeData.accentColor,
        ),
      ),
    );
  }

  Widget buildNameAndLastMsg(BuildContext context, ThemeData theme){
    FontWeight read = FontWeight.normal;
    TextStyle nameStyle = theme.primaryTextTheme.title.copyWith(fontWeight: read);
    TextStyle lastMsgStyle = theme.primaryTextTheme.body1.copyWith(fontWeight: read);

    return Expanded(
      child: Container(
        color: Colors.transparent,
        padding: EdgeInsets.symmetric(horizontal: 8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: EdgeInsets.only(bottom: 5.0),
              child: Text(data.name, style: nameStyle, overflow: TextOverflow.ellipsis),
            ),

            Text(data.messages[data.messages.length-1].text, style: lastMsgStyle, overflow: TextOverflow.ellipsis)
          ],
        ),
      ),
    );
  }

  Widget buildTimeAndBell(BuildContext context, ThemeData theme){
    TextStyle timeStampStyle = theme.primaryTextTheme.caption;

    return Container(
      color: Colors.transparent,
      child: AnimatedIconSwitch(
        unselected: Icons.notifications_off,
        selected: Icons.notifications,
        top: Text(dateTimeString, style: timeStampStyle),
        duration: Duration(milliseconds: 200),
        onPressed: (selected){},
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
    timer.cancel();
    super.dispose();
  }
}