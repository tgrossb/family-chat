import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:bodt_chat/constants.dart';


class User {
  final String uid;
  Map values;
  UserParameter<String> _name;
  UserParameter<String> _email;
  UserParameter<String> _cellphone;
  UserParameter<String> _homePhone;
  UserParameter<String> _dob;

  User({@required this.uid, @required String name}){
    _name = UserParameter(name: DatabaseConstants.kUSER_NAME, value: name, private: false);
    _email = null;
    _cellphone = null;
    _homePhone = null;
    _dob = null;
  }

  User.fromParams({@required this.uid, @required UserParameter<String> name,
                    UserParameter<String> email, UserParameter<String> cellphone,
                    UserParameter<String> homePhone, UserParameter<String> dob}):
      this._name = name,
      this._email = email,
      this._cellphone = cellphone,
      this._homePhone = homePhone,
      this._dob = dob;

  static UserParameter<T> stripFromValues<T>([String name, Map values, bool private = false]){
    return values.containsKey(name) ? UserParameter<T>(name: name, value: values[name], private: private) : null;
  }

  User.fromValues({@required this.uid, @required this.values}){
    // This is guaranteed to exist thanks to the database rules
    _name = UserParameter(name: DatabaseConstants.kUSER_NAME, value: values[DatabaseConstants.kUSER_NAME], private: false);

    // These are not guaranteed
    // Assume that these are not private because they have been given
    _email = stripFromValues(DatabaseConstants.kUSER_EMAIL, values);
    _cellphone = stripFromValues(DatabaseConstants.kUSER_CELLPHONE, values);
    _homePhone = stripFromValues(DatabaseConstants.kUSER_HOME_PHONE, values);
    _dob = stripFromValues(DatabaseConstants.kUSER_DOB, values);
  }

  User.fromSnapshot({@required String uid, @required DataSnapshot snapshot}):
        this.fromValues(uid: uid, values: snapshot.value);

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
  get homePhone => homePhone.value;
  get dob => dob.value;

  set name(String name) => _name.value = name;
  set email(String email) => _email.value = email;
  set cellphone(String cellphone) => _cellphone.value = cellphone;
  set homePhone(String homePhone) => _homePhone.value = homePhone;
  set dob(String dob) => _dob.value = dob;
}

class Me extends User {
  // This is needed for registering new users
  Me.fromParams({@required String uid, @required UserParameter<String> name,
                  UserParameter<String> email, UserParameter<String> cellphone,
                  UserParameter<String> homePhone, UserParameter<String> dob}):
      super.fromParams(uid: uid, name: name, email: email, cellphone: cellphone, homePhone: homePhone, dob: dob);

  // This is just needed for the factory
  Me.fromValues({@required String uid, @required Map values}):
    super.fromValues(uid: uid, values: values);

  // The datasnapshot for Me includes public and private data
  factory Me.fromSnapshots({@required String uid, @required DataSnapshot public, @required DataSnapshot private}){
    // Flatten the snapshot to remove public and private distinction
    Map values = {};
    values.addAll(public.value);
    values.addAll(private.value);

    // Use the values and the uid to construct the user
    Me me =  Me.fromValues(uid: uid, values: values);

    // Set the proper public/private values
    // All are set to public by default, so check for existence in the private set
    me._email.setPrivate(stripPrivate(DatabaseConstants.kUSER_EMAIL, uid, private.value));
    me._cellphone.setPrivate(stripPrivate(DatabaseConstants.kUSER_CELLPHONE, uid, private.value));
    me._homePhone.setPrivate(stripPrivate(DatabaseConstants.kUSER_HOME_PHONE, uid, private.value));
    me._dob.setPrivate(stripPrivate(DatabaseConstants.kUSER_DOB, uid, private.value));

    return me;
  }

  static bool stripPrivate(String name, String uid, Map values){
    return values.containsKey(name);
  }

  Map toDatabaseChild(){
    Map public = {};
    Map private = {};

    List<UserParameter> params = [_name, _email, _cellphone, _homePhone, _dob];
    for (UserParameter param in params) {
      if (param.private)
        private[param.name] = param.value;
      else
        public[param.name] = param.value;
    }

    return {uid: {DatabaseConstants.kUSER_PUBLIC_VARS: public, DatabaseConstants.kUSER_PRIVATE_VARS: private}};
  }
}

class UserParameter<T> {
  String name;
  T value;
  bool private;

  UserParameter({@required this.name, @required this.value, this.private = true}){
    if (name == DatabaseConstants.kUSER_NAME)
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