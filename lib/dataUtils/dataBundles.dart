import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:bodt_chat/dataUtils/user.dart';
import 'package:bodt_chat/utils.dart';
import 'package:bodt_chat/constants.dart';


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

  ResponsibleList({@required this.key, Map<String, String> initialData}){
    responsibleList = Map.of(initialData);
    _registerStringParam(this.key, "key");
  }

  bool addEntry(String uid, String responsible){
    if (responsibleList.containsKey(uid))
      return false;
    responsibleList[uid] = responsible;
    return true;
  }

  Map toDatabaseChild(){
    return {key: responsibleList};
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

//  factory GroupData.fromSnapshot({@required Map groupData}){
//    return GroupData(utcTime: null, uid: null, name: null, messages: null, admins: null, members: null, groupThemeData: null);
//  }

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

  factory GroupThemeData.fromSnapshotValue({@required Map groupThemeData}){
    int parsedColor = 0xff79baba;
    try {
      parsedColor = int.parse(groupThemeData[DatabaseConstants.kGROUP_COLOR_CHILD], radix: 16);
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

  factory MessageData.fromSnapshotValue({@required Map message, @required String time}){
    String senderUid = message[DatabaseConstants.kMESSAGE_SENDER_UID_CHILD];
    String text = message[DatabaseConstants.kMESSAGE_TEXT_CHILD];
    return MessageData(text: text, senderUid: senderUid, utcTime: Utils.parseTime(time));
  }

  String text;
  String senderUid;
  DateTime utcTime;

  Map toDatabaseChild(){
    return {
      utcTime: {
        DatabaseConstants.kMESSAGE_SENDER_UID_CHILD: senderUid,
        DatabaseConstants.kMESSAGE_TEXT_CHILD: text
      }
    };
  }

  @override
  bool operator ==(other) {
    MessageData otherData = other;
    return text == otherData.text && senderUid == otherData.senderUid && utcTime.millisecondsSinceEpoch == otherData.utcTime.millisecondsSinceEpoch;
  }

  @override
  // TODO: Don't think this will be used, but could break
  int get hashCode {
    print("This shouldn't happen, but it did (hashCode was used for messageData)");
    return utcTime.millisecondsSinceEpoch;
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