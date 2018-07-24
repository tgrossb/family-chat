import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'dart:async';
import 'dart:math' as math;
import 'package:bodt_chat/groups/groupsListScreen.dart';

class SplashPage extends StatefulWidget {
  @override
  State createState() => new _SplashPageState();
}

class SineAnimation extends Tween<Offset> {
  SineAnimation({Offset begin, Offset end}): super(begin: begin, end: end);

  Offset lerp(double t){
    return new Offset(0.0, math.sin(t * math.pi));
  }
}

class _SplashPageState extends State<SplashPage> with SingleTickerProviderStateMixin {
  final double ballDiameter = 10.0;
  final Offset maxHeight = new Offset(0.0, 10.0);
  final Duration period = new Duration(milliseconds: 700);

  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  final GoogleSignIn gSignIn = new GoogleSignIn();
  bool signingIn = true;
  AnimationController controller;
  Animation<Offset> firstHeight;

  @override
  void initState(){
    super.initState();

    controller = new AnimationController(
        duration: period,
        vsync: this);
    firstHeight = new SineAnimation(begin: Offset.zero, end: maxHeight).animate(controller);
    firstHeight..addListener(() => setState((){}))
                ..addStatusListener((status){
                  if (status == AnimationStatus.completed){
                    if (signingIn)
                      controller.reverse();
                  } else if (status == AnimationStatus.dismissed){
                    if (signingIn)
                      controller.forward();
                  }
                });
    controller.forward();
    
//    signingIn = false;
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
      body: new Container(
        color: Theme.of(context).primaryColor,
        child: new Center(
          child: signingIn ? new CircularProgressIndicator(
            valueColor: new AlwaysStoppedAnimation<Color>(Theme.of(context).splashColor),
          ) :
            new RaisedButton(
              onPressed: () => signInFlow(context),
              child: new Text("Sign In With Google", style: TextStyle(color: Colors.white),),
              color: Theme.of(context).splashColor,
            ),
        )
      ),
    );
  }

  Widget buildProgressIndicator(){
    return new Row(
      children: <Widget>[
        buildCircle(ballDiameter, Colors.green),
        buildCircle(ballDiameter, Colors.blue),
        buildCircle(ballDiameter, Colors.red),
        buildCircle(ballDiameter, Colors.yellow)
      ],
    )
  }

  Widget buildCircle(double d, Color color){
    return new Container(
      width: d,
      height: d,
      decoration: new BoxDecoration(
        color: color,
        shape: BoxShape.circle
      ),
    );
  }

  @override
  void @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}
