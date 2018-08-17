import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:bodt_chat/utils.dart';

class Data {
  List<String> _empties = [];
  List<String> _params = [];
  
  bool get hasEmpty => _empties.length > 0;
  String get stringEmpties => _empties.join(", ");

  bool isEmpty(String param){
    if (!_params.contains(param))
      throw new ArgumentError("Parameter $param not in parameter list (" + _params.join(",") + ")");
    else
      return _empties.contains(param);
  }
  
  void _registerStringParam(String value, String paramName){
    _registerObjectParam(value, paramName, (String s) => !Utils.textNotEmpty(s));
  }

  void _registerListParam(List<Object> value, String paramName){
    _registerObjectParam(value, paramName, (List<Object> l) => l.length == 0);
  }

  void _registerObjectParam<T>([T value, String paramName, bool Function(T) objIsEmpty]){
    print("Registered parameter '$paramName' with value '" + value.toString() + "'");
    _params.add(paramName);
    if (value == null || (objIsEmpty != null && objIsEmpty(value)))
      _empties.add(paramName);
  }
}

/*
 * This is the packaged data for the list of groups.
 *
 * This screen is displayed after the splash page if the
 * user sign in is correct.
 */
class GroupsListData extends Data {
  GroupsListData({@required this.user, @required this.groupsData}){
    _registerObjectParam(this.user, "user");
    _registerListParam(this.groupsData, "groupsData");
  }

  // This is the user discovered from the sign in.
  // TODO: Replace with a uuid
  FirebaseUser user;

  // This is a list of data for groups that were discovered from the preload.
  // This list has an uncertain length, and each element corresponds to a group
  List<GroupData> groupsData;
}

/*
 * This is the packaged data for a single group.
 *
 * This is used to display groups on the group list screen, and it is
 * also used when a group is started and the group screen is displayed.
 */
class GroupData extends Data {
//  GroupData({this.rawTime, this.time, this.utcTime, this.name, this.firstMessages});
  GroupData({@required this.utcTime, @required this.name, @required this.firstMessages});

  GroupData.fromRawTime({@required String rawTime, @required this.name, @required this.firstMessages}):
        this.utcTime = Utils.parseTime(rawTime) {
    _registerStringParam(this.name, "name");
    _registerObjectParam(this.utcTime, "utcTime");
    _registerListParam(this.firstMessages, "firstMessages");
  }

  // This is the unformatted string of the DateTime utcTime.
  // It is the ISO 8601 string of the utc time.
  // THIS SHOULD NOT BE NEEDED
//  String rawTime;

  // This is the name of the group.
  // TODO: Add a uuid?
  String name;

  // This is the readable version of the time.
  // Use the Utils.formatTime or Utils.timeToFormedString methods to
  // ensure consistency.
  // THIS SHOULD NOT BE NEEDED
//  String time;

  // This is the utc time of the last message.
  DateTime utcTime;

  // This is a list of the first messages in this group.
  // This list has an unspecified length because as much data is preloaded as possible.
  List<MessageData> firstMessages;

  @override
  String toString() {
    return "[" + name + " @ " + utcTime.toString() + " with " + firstMessages.length.toString() + " init msgs]";
  }
}

/*
 * This is the packaged data for the specific implementation of a group.
 *
 * These objects specify the behavior of the group, and do not contain
 * any group-specific data.
 */
class GroupImplementationData extends Data {
  GroupImplementationData({this.start, this.delete, this.animationController}){
    _registerObjectParam(this.start, "start");
    _registerObjectParam(this.delete, "delete");
    _registerObjectParam(this.animationController, "animationController");
  }

  // This is the function used to start the group.
  // This is called when a group is clicked on, and triggers
  // the transition to the group screen
  Function start;

  // This is the function used to delete the group.
  // This is called when the delete group dialog is confirmed.
  Function delete;

  // This is the animation controller that controls the enter animation
  // for the group.
  // This is used for the bounce-in effect that groups list items have.
  AnimationController animationController;
}

/*
 * This is the packaged data for a message.
 *
 * This package contains the essential data to a message.
 */
class MessageData extends Data {
  MessageData({@required this.text, @required this.name, @required this.utcTime}) {
    _registerStringParam(this.text, "text");
    _registerStringParam(this.name, "name");
    _registerObjectParam(this.utcTime, "utcTime");
  }

  // This is the actual text of the message.
  String text;

  // This is the name of the user that sent the message.
  // TODO: Add or replace with a uuid?
  String name;

  // This is the time at which the message was sent, in the UTC timezone
  DateTime utcTime;

  // This is a list of the null parameters, used for debugging
  List<String> _nulls;

  @override
  bool operator ==(other) {
    MessageData otherData = other;
    return text == otherData.text && name == otherData.name && utcTime.millisecondsSinceEpoch == otherData.utcTime.millisecondsSinceEpoch;
  }

  @override
  // TODO: Don't think this will be used, but could break
  int get hashCode {
    print("This shouldn't happen, but it did (hashCode was used for messageData)");
    return utcTime.millisecondsSinceEpoch;
  }
}