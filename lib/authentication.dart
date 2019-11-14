import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:hermes/user.dart';

class Auth {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  Future<User> signIn(String email, String password) async {
    AuthResult res;
    try {
      res = await _firebaseAuth.signInWithEmailAndPassword(email: email, password: password);
    } on PlatformException catch(e) {
      print(e.code);
      print(e.message);
      return User.nullUser();
    }
    return User.fromFirebaseUser(res.user);
  }

  Future<User> signUp(String email, String password) async {
    AuthResult res = await _firebaseAuth.createUserWithEmailAndPassword(email: email, password: password);
    return User.fromFirebaseUser(res.user);
  }

  Future<User> getCurrentUser() async {
    FirebaseUser user = await _firebaseAuth.currentUser();
    return User.fromFirebaseUser(user);
  }

  Future<void> signOut() async {
    return _firebaseAuth.signOut();
  }

  Future<void> sendEmailVerification() async {
    FirebaseUser user = await _firebaseAuth.currentUser();
    user.sendEmailVerification();
  }
}