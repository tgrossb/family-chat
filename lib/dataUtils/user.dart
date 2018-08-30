import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:bodt_chat/constants.dart';


class User {
  final String uid;
  Map values;
  UserParameter<String> _name;
  UserParameter<String> _email;
  UserParameter<String> _cellphone;

  User({@required this.uid, @required String name}){
    _name = UserParameter(name: kUSER_NAME, value: name, private: false);
    _email = null;
    _cellphone = null;
  }

  User.fromValues({@required this.uid, @required this.values}){
    // This is guaranteed to exist thanks to the database rules
    _name = UserParameter(name: kUSER_NAME, value: values[kUSER_NAME], private: false);

    // These are not guaranteed
    // Assume that these are not private because they have been given
    _email = values.containsKey(kUSER_EMAIL) ? UserParameter(name: kUSER_EMAIL, value: values[kUSER_EMAIL], private: false) : null;
    _cellphone = values.containsKey(kUSER_CELLPHONE) ? UserParameter(name: kUSER_CELLPHONE, value: values[kUSER_CELLPHONE], private: false) : null;
  }

  User.fromSnapshot({@required String uid, @required DataSnapshot snapshot}): this.fromValues(uid: uid, values: snapshot.value[kUSER_PUBLIC_VARS]);

  @override
  bool operator ==(other) {
    if (!(other is User))
      return false;
    User otherUser = other;
    return uid == otherUser.uid;
  }

  @override
  int get hashCode => uid.hashCode;

  @override
  String toString() {
    return "$name ($uid)";
  }

  get name => _name.value;
  get email => _email.value;
  get cellphone => _cellphone.value;

  set name(String name) => _name.value = name;
  set email(String email) => _email.value = email;
  set cellphone(String cellphone) => _cellphone.value = cellphone;
}

class Me extends User {
  // This is just needed for the factory
  Me.fromValues({@required String uid, @required Map values}):
    super.fromValues(uid: uid, values: values);

  // The datasnapshot for Me includes public and private data
  factory Me.fromSnapshot({@required DataSnapshot snapshot}){
    // The uid it the root of the values
    String uid = snapshot.value.keys[0];

    // Flatten the snapshot to remove public and private distinction
    Map values = {};
    values.addAll(snapshot.value[uid][kUSER_PUBLIC_VARS]);
    values.addAll(snapshot.value[uid][kUSER_PRIVATE_VARS]);

    // Use the values and the uid to construct the user
    Me me =  Me.fromValues(uid: uid, values: values);

    // Set the proper public/private values
    // All are set to public by default, so check for existence in the private set
    if (snapshot.value[uid][kUSER_PRIVATE_VARS].containsKey(kUSER_EMAIL))
      me.email.makePrivate();
    if (snapshot.value[uid][kUSER_PRIVATE_VARS].containsKey(kUSER_EMAIL))
      me.email.makePrivate();

    return me;
  }

  Map toDatabaseChild(){
    Map public = {};
    Map private = {};

    List<UserParameter> params = [name, email, cellphone];
    for (UserParameter param in params) {
      if (param.private)
        private[param.name] = param.value;
      else
        public[param.name] = param.value;
    }

    return {uid: {kUSER_PUBLIC_VARS: public, kUSER_PRIVATE_VARS: private}};
  }
}

class UserParameter<T> {
  String name;
  T value;
  bool private;

  UserParameter({@required this.name, @required this.value, this.private = true}){
    if (name == kUSER_NAME)
      private = false;
  }

  void makePublic() {
    private = false;
  }

  void makePrivate(){
    private = true;
  }

  void setPrivate(bool newPrivate){
    private = newPrivate;
  }

  @override
  String toString() {
    return value.toString();
  }

  @override
  bool operator ==(other) {
    if (!(other is UserParameter))
      return false;
    UserParameter otherParam = other;
    return value == otherParam.value;
  }

  @override
  // TODO: implement hashCode
  int get hashCode => value.hashCode;
}