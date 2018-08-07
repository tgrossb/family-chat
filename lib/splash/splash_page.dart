import 'package:flutter/material.dart';
import 'package:flutter/animation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'dart:async';
import 'dart:math' as math;
import 'package:bodt_chat/groups/groupsListScreen.dart';
import 'package:bodt_chat/groups/groupsListItem.dart';
import 'package:bodt_chat/splash/loadingAnimationWidget.dart';
import 'package:bodt_chat/splash/signInButton.dart';
import 'package:bodt_chat/routes.dart';
import 'package:bodt_chat/constants.dart';

class SplashPage extends StatefulWidget {
  @override
  State createState() => new _SplashPageState();
}

class _SplashPageState extends State<SplashPage> with TickerProviderStateMixin {
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  final GoogleSignIn gSignIn = new GoogleSignIn();
  final GlobalKey<ScaffoldState> scaffoldKey = new GlobalKey<ScaffoldState>();
  bool loading = false, startFinishFlag = false, finishingStarted = false, finished = false;
  GroupsListData groupsListData;

  AnimationController loadingAnimationController, signInButtonToLoadingController;
  Animation<double> loadingAnimation;
  int animationCount = 0;

  @override
  void initState(){
    super.initState();

    signInButtonToLoadingController = AnimationController(vsync: this, duration: new Duration(milliseconds: 1500));
    signInButtonToLoadingController.addStatusListener((status){
      if (status == AnimationStatus.completed) {
        startLoading();
        signInButtonToLoadingController.reset();
      }
    });

    loadingAnimationController = AnimationController(vsync: this, duration: new Duration(milliseconds: 1500));
    loadingAnimation = Tween(begin: 0.0, end: 2*math.pi).animate(loadingAnimationController);

    loadingAnimation.addStatusListener((status) {
      bool incCount = false;
      bool setCountToFinish = false;
      if (status == AnimationStatus.completed) {
        if (loading || startFinishFlag) {
          loadingAnimationController.forward(from: 0.0);
          incCount = true;
        } if (startFinishFlag){
          startFinishFlag = false;
          finishingStarted = true;
          setCountToFinish = true;
        } else if (finishingStarted){
          finishingStarted = false;
          finished = true;
          print("Finished completely");
          navigateToGroups(groupsListData);
        }
      }

      if (setCountToFinish)
        setState(() {
          animationCount = kLOADING_FINISH;
        });
      else if (incCount)
        setState(() {
          animationCount++;
        });
    });

    loading = false;
//    attemptSilentSignIn().then((FirebaseUser user) => startLoading(user));
//    silentSignInProcess();
//    fakeSignIn(10);
  }

  void silentSignInProcess() async {
    FirebaseUser user = await attemptSilentSignIn();
    startLoading(user);
  }

  void startLoading([FirebaseUser user]) async {
    setState(() {
      loading = true;
      loadingAnimationController.forward();
    });

    if (user == null)
      user = await attemptSignIn();

    if (user == null){
      SnackBar snackBar = new SnackBar(content: new Text("There was an error signing you in"));
      scaffoldKey.currentState.showSnackBar(snackBar);
      setState((){
        loading = false;
        startFinishFlag = false;
        finishingStarted = false;
        finished = false;
      });
      loadingAnimationController.stop(canceled: false);
      print("User is null, problem");
      return;
    }

    List<GroupData> groupsData = await loadGroupsData();

    // This should be at the very bottom of this method
    // It signifies loading is finished, start the finish process with received data
    setState((){
      loading = false;
      startFinishFlag = true;
      groupsListData = new GroupsListData(user: user, groupsData: groupsData);
    });
  }

  Future<List<GroupData>> loadGroupsData() async {
    List<GroupData> groupsData = [];

    FirebaseDatabase db = FirebaseDatabase.instance;
    db.setPersistenceEnabled(true);

    DatabaseReference mainRef = db.reference();
    StreamSubscription addSub = mainRef.onChildAdded.listen((Event event) async {
      String groupName = event.snapshot.key;
      Event lastMessageReceived = await mainRef.child(groupName).child(kMESSAGES_CHILD).limitToLast(1).onChildAdded.first;
      GroupData data = new GroupData(
        name: event.snapshot.key,
        rawTime: lastMessageReceived.snapshot.key,
      );
      groupsData.add(data);
    });
    addSub.cancel();
    return groupsData;
  }

  void navigateToGroups(GroupsListData data){
    if (groupsListData == null) {
      scaffoldKey.currentState.showSnackBar(
          SnackBar(content: Text("This is problematic")));
      return;
    }
    Navigator.of(context).pushReplacement(new InstantRoute(widget: new GroupsListScreen(data: groupsListData)));
  }

//  void handleUser(FirebaseUser user){
//    setState(() {
//      loading = false;
//      if (user != null) {
//        startFinishFlag = true;
//        recievedUser = user;
//      }
//    });
//  }

  Future<FirebaseUser> attemptSilentSignIn() async {
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

  Future<FirebaseUser> attemptSignIn() async {
    GoogleSignInAccount account = await gSignIn.signIn();
    FirebaseUser user = await signInFromGAccount(account);
    return user;
  }


  Future<FirebaseUser> signInFromGAccount(GoogleSignInAccount account) async {
    GoogleSignInAuthentication gAuth = await account.authentication;

    FirebaseUser user;
    try {
      user = await firebaseAuth.signInWithGoogle(
          idToken: gAuth.idToken, accessToken: gAuth.accessToken);
    } catch(e){
      return null;
    }

    return user;
  }

  @override
  Widget build(BuildContext context) {
    print("Rebuild  count: $animationCount");

    return new Scaffold(
      key: scaffoldKey,
      body: new Container(
        color: Theme.of(context).primaryColor,
        child: new Center(
          child: loading || startFinishFlag || finishingStarted || finished ?
            new Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                new LoadingAnimationWidget(animation: loadingAnimation, count: animationCount),
//                new Padding(
//                    padding: EdgeInsets.all(LoadingAnimationWidget.padding),
//                    child: new Text("Signing you in", style: TextStyle(color: Colors.white)),
//                )
              ],
            ) :

            new SignInButton(
              controller: signInButtonToLoadingController,
              startAnimation: () => signInButtonToLoadingController.forward()
            ),
        ),
      ),
    );
  }


  @override
  void dispose() {
    signInButtonToLoadingController.dispose();
    loadingAnimationController.dispose();
    super.dispose();
  }
}