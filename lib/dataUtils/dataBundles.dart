import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:bodt_chat/dataUtils/user.dart';
import 'package:bodt_chat/utils.dart';
import 'package:bodt_chat/constants.dart';
import 'package:firebase_database/firebase_database.dart';


class Data {
  static final bool reportRegisters = false;

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
    if (reportRegisters)
      print("Registered parameter '$paramName' with value '" + value.toString() + "'");
    _params.add(paramName);
    if (value == null || (objIsEmpty != null && objIsEmpty(value)))
      _empties.add(paramName);
  }

  // Many inherited classes present the method toDatabaseChild, and this is useful for that method
  Map orphanable(Map m, bool orphan){
    if (orphan)
      return Utils.stripParent(m);
    return m;
  }
}

/*
 * This is the packaged data for a list of uids with responsibility.
 *
 * That means that it contains a map of who added each uid to the list.
 * The key is used for serialization to the database.
 */
class ResponsibleList extends Data {
  String key;
  Map<String, String> responsibleList;
  bool ignoreKeepers;

  ResponsibleList({@required this.key, Map<String, String> initialData, this.ignoreKeepers = false}){
    responsibleList = initialData == null ? Map() : Map.of(initialData);
    if (ignoreKeepers && responsibleList.containsKey(DatabaseConstants.kKEEPER_KEY))
      responsibleList.remove(DatabaseConstants.kKEEPER_KEY);
    _registerStringParam(this.key, "key");
  }

  /*
   * Assume that data takes the form
   * {
   *   key: {
   *     uid1: responsible1,
   *     uid2: responsible2,
   *   }
   * }
   */
  factory ResponsibleList.fromSnapshot({@required DataSnapshot snapshot, bool ignoreKeepers = false}){
    String key = snapshot.key;
    Map<String, String> initialData = {};
    snapshot.value.forEach((uid, responsible) => (initialData[uid] = responsible));
    return ResponsibleList(key: key, initialData: initialData, ignoreKeepers: ignoreKeepers);
  }

  bool addEntry(String uid, String responsible){
    if (responsibleList.containsKey(uid))
      return false;
    if (ignoreKeepers && uid == DatabaseConstants.kKEEPER_KEY)
      return false;
    responsibleList[uid] = responsible;
    return true;
  }

  bool removeEntry(String uid){
    if (!responsibleList.containsKey(uid))
      return false;
    responsibleList.remove(uid);
    return true;
  }

  Map toDatabaseChild({bool orphan = false}){
    return orphanable({key: responsibleList}, orphan);
  }

  @override
  String toString() {
    return responsibleList.toString();
  }
}

/*
 * This is the packaged data for a single group.
 *
 * This is used to display groups on the group list screen, and it is
 * also used when a group is started and the group screen is displayed.
 */
class GroupData extends Data {
  // This class bundles the group's uid, name, the time of the last message, a list of messages,
  // a list of members and admins, and the group's theme data
  String uid;
  String name;
  List<MessageData> messages;
  ResponsibleList admins;
  ResponsibleList members;
  GroupThemeData groupThemeData;

  DateTime get utcTime => messages[messages.length-1].utcTime;

  GroupData({@required this.uid, @required this.name, @required this.messages,
    @required this.admins, @required this.members, @required this.groupThemeData}){
    _registerStringParam(this.uid, "uid");
    _registerStringParam(this.name, "name");
    _registerListParam(this.messages, "messages");
    _registerObjectParam(this.admins, "admins");
    _registerObjectParam(this.members, "members");
    _registerObjectParam(this.groupThemeData, "groupTheme");
  }

  Map toDatabaseChild({bool orphan = false}){
    Map messagesMap = {};
    for (MessageData message in messages)
      messagesMap.addAll(message.toDatabaseChild());

    return orphanable({
      uid: {
        DatabaseConstants.kGROUP_NAME_CHILD: name,
        DatabaseConstants.kGROUP_ADMINS_CHILD: admins.toDatabaseChild(orphan: true),
        DatabaseConstants.kGROUP_MEMBERS_CHILD: members.toDatabaseChild(orphan: true),
        DatabaseConstants.kGROUP_MESSAGES_CHILD: messagesMap,
        DatabaseConstants.kGROUP_THEME_DATA_CHILD: groupThemeData.toDatabaseChild(orphan: true)
      }
    }, orphan);
  }

  @override
  bool operator ==(other) {
    if (!(other is GroupData))
      return false;
    return uid == other.uid;
  }

  @override
  int get hashCode => uid.hashCode;

  @override
  String toString() {
    return "[GroupData $name @ $utcTime with ${messages.length} msgs]";
  }
}

/*
 * This is the packaged data for a group theme.
 *
 * The group theme contains information regarding the appearance of a group
 * that persists across users.
 */
class GroupThemeData extends Data {
  Color accentColor, backgroundColor;
  GroupThemeData({@required this.accentColor, @required this.backgroundColor}){
    _registerObjectParam(this.accentColor, "accentColor");
    _registerObjectParam(this.backgroundColor, "backgroundColor");
  }

  factory GroupThemeData.fromSnapshot({@required DataSnapshot snapshot}){
    String accentString = snapshot.value[DatabaseConstants.kGROUP_ACCENT_COLOR_CHILD];
    Color accentColor = Utils.stringToColor(accentString, DatabaseConstants.kGROUP_ACCENT_COLOR_DEFAULT);

    String backgroundString = snapshot.value[DatabaseConstants.kGROUP_BACKGROUND_COLOR_CHILD];
    Color backgroundColor = Utils.stringToColor(backgroundString, DatabaseConstants.kGROUP_BACKGROUND_COLOR_DEFAULT);
    return GroupThemeData(accentColor: accentColor, backgroundColor: backgroundColor);
  }

  void updateFromChangeSnapshot(DataSnapshot snapshot){
    if (snapshot.key == DatabaseConstants.kGROUP_ACCENT_COLOR_CHILD)
      accentColor = Utils.stringToColor(snapshot.value, DatabaseConstants.kGROUP_ACCENT_COLOR_DEFAULT);

    else if (snapshot.key == DatabaseConstants.kGROUP_BACKGROUND_COLOR_CHILD)
      backgroundColor = Utils.stringToColor(snapshot.value, DatabaseConstants.kGROUP_BACKGROUND_COLOR_DEFAULT);

    else if (snapshot.key == DatabaseConstants.kGROUP_THEME_DATA_CHILD)
      copyFrom(GroupThemeData.fromSnapshot(snapshot: snapshot));
  }

  void copyFrom(GroupThemeData other){
    accentColor = other.accentColor;
    backgroundColor = other.backgroundColor;
  }

  Map toDatabaseChild({bool orphan = false}){
    return orphanable({
      DatabaseConstants.kGROUP_THEME_DATA_CHILD: {
        DatabaseConstants.kGROUP_ACCENT_COLOR_CHILD: Utils.colorToString(accentColor),
        DatabaseConstants.kGROUP_BACKGROUND_COLOR_CHILD: Utils.colorToString(backgroundColor)
      }
    }, orphan);
  }

  @override
  bool operator ==(other) {
    if (!(other is GroupThemeData))
      return false;
    return hashCode == other.hashCode;
  }

  @override
  int get hashCode => accentColor.value;

  @override
  String toString() {
    return "[GroupThemeData accentColor: $accentColor]";
  }
}


/*
 * This is the packaged data for a message.
 *
 * This package contains the essential data to a message.
 */
class MessageData extends Data {
  MessageData({@required this.text, @required this.senderUid, @required this.utcTime}) {
    _registerStringParam(this.text, "text");
    _registerStringParam(this.senderUid, "senderUid");
    _registerObjectParam(this.utcTime, "utcTime");
  }

  factory MessageData.fromMap({@required Map map, @required String time}){
    String senderUid = map[DatabaseConstants.kMESSAGE_SENDER_UID_CHILD];
    String text = map[DatabaseConstants.kMESSAGE_TEXT_CHILD];
    return MessageData(text: text, senderUid: senderUid, utcTime: Utils.parseTime(time));
  }

  factory MessageData.fromSnapshot({@required DataSnapshot snap}){
    return MessageData.fromMap(map: snap.value, time: snap.key);
  }

  String text;
  String senderUid;
  DateTime utcTime;

  Map toDatabaseChild({bool orphan = false}){
    return orphanable({
      Utils.timeToKeyString(utcTime): {
        DatabaseConstants.kMESSAGE_SENDER_UID_CHILD: senderUid,
        DatabaseConstants.kMESSAGE_TEXT_CHILD: text
      }
    }, orphan);
  }

  @override
  bool operator ==(other) {
    if (!(other is MessageData))
      return false;
    return utcTime.millisecondsSinceEpoch == other.utcTime.millisecondsSinceEpoch;
  }

  @override
  int get hashCode => utcTime.millisecondsSinceEpoch;

  @override
  String toString() {
    String excerpt = text.substring(0, text.length > 10 ? 10 : text.length);
    return "[MessageData senderUid: $senderUid  time: $utcTime  text: $excerpt]";
  }
}

/*
 * This class is the logic and parameters of a SimpleInput widget.
 * This is everything but the gui, location, and text input level validator,
 */
class InputFieldParams extends Data {
  String label, requiredLabel;
  Function(String, UserParameter<String>, bool, String, Function) validator;
  IconData icon;
  bool isRequired, switchValue, autovalidate, useNew, useCountryPicker;
  List<TextInputFormatter> formatters;
  TextInputType keyboardType;
  FocusNode focusNode;
  Widget Function(BuildContext) buildPrefix;
  Function(CountryData) onSelected;

  // Default values are assumed by SimpleInput
  InputFieldParams({@required this.label, @required this.validator, @required this.icon, String requiredLabel, this.useNew, this.buildPrefix,
                    this.formatters, this.keyboardType, FocusNode focusNode, this.isRequired, this.switchValue, this.autovalidate,
                    this.useCountryPicker, this.onSelected}):
        requiredLabel = requiredLabel ?? "* ",
        focusNode = focusNode ?? new FocusNode(){
    _registerStringParam(label, "label");
    _registerStringParam(requiredLabel, "requiredLabel");
    _registerObjectParam(validator, "validator");
    _registerObjectParam(icon, "icon");
    _registerListParam(formatters, "formatters");
    _registerObjectParam(keyboardType, "keyboardType");
    _registerObjectParam(this.focusNode, "focusNode");
    _registerObjectParam(isRequired, "isRequired");
    _registerObjectParam(switchValue, "switchValue");
    _registerObjectParam(autovalidate, "autovalidate");
    _registerObjectParam(buildPrefix, "prefix");
    _registerObjectParam(useCountryPicker, "useCountryPicker");
    _registerObjectParam(onSelected, "onSelected");
    _registerObjectParam(useNew, "useNew");
  }
}

class CountryData extends Data {
  String name, isoCode, phoneCode;
  Image flag;

  CountryData({@required this.name, @required this.isoCode, @required this.phoneCode}):
        flag = Image.asset('assets/flags/${isoCode.toUpperCase()}.png', fit: BoxFit.cover) {
    _registerStringParam(name, "name");
    _registerStringParam(isoCode, "isoCode");
    _registerStringParam(phoneCode, "phoneCode");
    _registerObjectParam(flag, "flag");
  }
}