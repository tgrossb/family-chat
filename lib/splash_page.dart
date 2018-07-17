import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'dart:async';
import 'groupsListScreen.dart';

class SplashPage extends StatefulWidget {
  @override
  State createState() => new _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  final GoogleSignIn gSignIn = new GoogleSignIn();
  bool signingIn = true;

  @override
  void initState(){
    super.initState();

    signingIn = true;
    attemptSilentSignIn(context).then((FirebaseUser user) => handleUser(user));
  }

  void handleUser(FirebaseUser user){
    if (user != null)
      Navigator.of(context).pushReplacement(new MaterialPageRoute(
          builder: (context) => new GroupsListScreen(user: user)));
    else
      setState(() {
        signingIn = false;
      });
  }

  Future<FirebaseUser> attemptSilentSignIn(BuildContext context) async {
    GoogleSignInAccount current = gSignIn.currentUser;
    if (current != null)
      return await signInFromGAccount(current);
    else {
      GoogleSignInAccount account = await gSignIn.signInSilently();
      if (account != null)
            return await signInFromGAccount(account);
    }

    return null;
  }

  Future<FirebaseUser> fullSignIn() async {
    GoogleSignInAccount account = await gSignIn.signIn();
    return signInFromGAccount(account);
  }


  Future<FirebaseUser> signInFromGAccount(GoogleSignInAccount account) async {
    GoogleSignInAuthentication gAuth = await account.authentication;

    FirebaseUser user = await firebaseAuth.signInWithGoogle(idToken: gAuth.idToken, accessToken: gAuth.accessToken);
    return user;
  }

  void signInFlow(BuildContext context){
    setState(() {
      signingIn = true;
    });

    fullSignIn().then((FirebaseUser user) => handleUser(user));
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text("Sign In"),
      ),
      body: new Center(
          child: signingIn ? new CircularProgressIndicator() :
            new RaisedButton(
              onPressed: () => signInFlow(context),
              child: new Text("Sign In With Google"),
              color: Theme.of(context).accentColor,
            ),
      ),
    );
  }
}
