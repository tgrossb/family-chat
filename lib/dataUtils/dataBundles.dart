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

  Map toDatabaseChild(){
    return {key: responsibleList};
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
  DateTime utcTime;
  List<MessageData> messages;
  ResponsibleList admins;
  ResponsibleList members;
  GroupThemeData groupThemeData;

  GroupData({@required this.utcTime, @required this.uid, @required this.name, @required this.messages,
    @required this.admins, @required this.members, @required this.groupThemeData}){
    _registerStringParam(this.uid, "uid");
    _registerStringParam(this.name, "name");
    _registerObjectParam(this.utcTime, "utcTime");
    _registerListParam(this.messages, "messages");
    _registerObjectParam(this.admins, "admins");
    _registerObjectParam(this.members, "members");
    _registerObjectParam(this.groupThemeData, "groupTheme");
  }

  factory GroupData.fromSnapshot({@required DataSnapshot snap}){
    return GroupData(
        utcTime: null,
        uid: null,
        name: null,
        messages: null,
        admins: null,
        members: null,
        groupThemeData: null
    );
  }

  Map toDatabaseChild(){
    Map messagesMap = {};
    for (MessageData message in messages)
      messagesMap.addAll(message.toDatabaseChild());

    return {
      uid: {
        DatabaseConstants.kGROUP_NAME_CHILD: name,
        DatabaseConstants.kGROUP_ADMINS_CHILD: admins.toDatabaseChild().values,
        DatabaseConstants.kGROUP_MEMBERS_CHILD: members.toDatabaseChild().values,
        DatabaseConstants.kGROUP_MESSAGES_CHILD: messagesMap,
        DatabaseConstants.kGROUP_THEME_DATA_CHILD: groupThemeData.toDatabaseChild().values
      }
    };
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
  Color groupColor;
  GroupThemeData({@required this.groupColor}){
    _registerObjectParam(this.groupColor, "groupColor");
  }

  factory GroupThemeData.fromSnapshot({@required DataSnapshot snapshot}){
    int parsedColor = 0xff79baba;
    try {
      parsedColor = int.parse(snapshot.value[DatabaseConstants.kGROUP_COLOR_CHILD], radix: 16);
    } catch (e){
      // Allow this to fail quietly
      print("Group color parsing has failed quietly");
    }
    
    return GroupThemeData(groupColor: Color(parsedColor));
  }

  Map toDatabaseChild(){
    return {
      DatabaseConstants.kGROUP_THEME_DATA_CHILD: {
        DatabaseConstants.kGROUP_COLOR_CHILD: groupColor.value
      }
    };
  }

  @override
  bool operator ==(other) {
    if (!(other is GroupThemeData))
      return false;
    return hashCode == other.hashCode;
  }

  @override
  int get hashCode => groupColor.value;

  @override
  String toString() {
    return "[GroupThemeData groupColor: $groupColor]";
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

  Map toDatabaseChild(){
    return {
      Utils.timeToKeyString(utcTime): {
        DatabaseConstants.kMESSAGE_SENDER_UID_CHILD: senderUid,
        DatabaseConstants.kMESSAGE_TEXT_CHILD: text
      }
    };
  }

  @override
  bool operator ==(other) {
    if (!(other is MessageData))
      return false;
    return utcTime.millisecondsSinceEpoch == other.utcTime.millisecondsSinceEpoch;
  }

  @override
  int get hashCode => utcTime.millisecondsSinceEpoch;
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