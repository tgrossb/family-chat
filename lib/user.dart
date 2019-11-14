import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class User {
  String uid;

  String email;

  bool isEmailVerified;

  User({@required this.uid, @required this.email, @required this.isEmailVerified});

  User.fromFirebaseUser(FirebaseUser user){
    uid = user.uid;
    email = user.email;
    isEmailVerified = user.isEmailVerified;
  }

  User.nullUser(){
    isEmailVerified = false;
  }

  bool isValid(){
    return uid != null && uid.length > 0 && email != null && email.length > 0;
  }
}