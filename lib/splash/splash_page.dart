/**
 * This is the splash page for the app.  It is the first page
 * show when the app starts, and handles possibly heavy loading.
 *
 * The process begins with user sign in, then loads the first few
 * messages from each group to create a smoother experience later in
 * the app (when a group is started).
 *
 * Written by: Theo Grossberndt
 */

import 'package:flutter/material.dart';
import 'package:flutter/animation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'dart:async';
import 'dart:math' as math;
import 'package:bodt_chat/groups/groupsListScreen.dart';
import 'package:bodt_chat/groups/groupsListItem.dart';
import 'package:bodt_chat/groupMessage.dart';
import 'package:bodt_chat/splash/loadingAnimationWidget.dart';
import 'package:bodt_chat/splash/signInButton.dart';
import 'package:bodt_chat/routes.dart';
import 'package:bodt_chat/constants.dart';
import 'package:bodt_chat/utils.dart';

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
      // Starts the loading animation when the sign in button animation,
      // which goes from button to loader, finishes.
      if (status == AnimationStatus.completed) {
        startLoading();
        signInButtonToLoadingController.reset();
      }
    });

    loadingAnimationController = AnimationController(vsync: this, duration: new Duration(milliseconds: 1500));
    loadingAnimation = Tween(begin: 0.0, end: 2*math.pi).animate(loadingAnimationController);

    loadingAnimation.addStatusListener((status) {
      // TODO: The whole flags to indicate finishing status thing needs to be rethought
      // It works, but I hate it
      bool incCount = false;
      bool setCountToFinish = false;
      if (status == AnimationStatus.completed) {
        // If it is loading or the finish flow needs to begin (aka. get
        // ready to collapse the loader) then restart the animation
        if (loading || startFinishFlag) {
          loadingAnimationController.forward(from: 0.0);
          incCount = true;
        }

        // If the finis flow needs to begin, start the finish flow,
        // reset the start finish flag for future use, and indicate the
        // start of the finish for the animated loader
        if (startFinishFlag){
          startFinishFlag = false;
          finishingStarted = true;
          setCountToFinish = true;
        }

        // Otherwise, if finishing had already started, reset the finishing
        // started flag for future use, indicate that loading has finished,
        // and start navigation to the groups screen.
        else if (finishingStarted){
          finishingStarted = false;
          finished = true;
          navigateToGroups(groupsListData);
        }
      }

      // Handle the animation count related flags in this method
      if (setCountToFinish)
        setState(() {
          animationCount = kLOADING_FINISH;
        });
      else if (incCount)
        setState(() {
          animationCount++;
        });
    });


    // Uncomment the next line and comment out the second line
    // to force the user to click the button to start the loading.
    // Useful for testing.
    loading = false;
//    silentSignInProcess();
  }

  // Starts the silent sign in for returning users.
  void silentSignInProcess() async {
    FirebaseUser user = await attemptSilentSignIn();
    startLoading(user);
  }

  // Starts the process of loading.
  // If a proper user is not passed, silent sign in is attempted.
  // If that is still unsuccessful, a full sign in is attempted.
  // If that is null, and error is raised.
  // Finally, it loads the first few messages of a group.
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

  // Loads base data about each group to avoid loading down the line.
  // Also loads the first few messages for each group.
  Future<List<GroupData>> loadGroupsData() async {
    List<GroupData> groupsData = [];

    FirebaseDatabase db = FirebaseDatabase.instance;
    db.setPersistenceEnabled(true);

    DatabaseReference mainRef = db.reference();
    StreamSubscription addSub = mainRef.onChildAdded.listen((Event event) async {
      String groupName = event.snapshot.key;

      // Get a list of the first few messages for this group
      List<Event> childEvents = await mainRef.child(groupName).child(kMESSAGES_CHILD).limitToLast(kGROUPS_PRELOAD).onChildAdded.toList();

      // Turn the events into full MessageData objects
      List<MessageData> childFirstMessages = [];
      for (Event childEvent in childEvents)
        childFirstMessages.add(new MessageData(
          text: childEvent.snapshot.value['text'],
          name: childEvent.snapshot.value['name'],
          time: Utils.parseTime(childEvent.snapshot.key),
        ));

      // Construct the data object for this group
      GroupData data = new GroupData(
        name: groupName,
        rawTime: childEvents[kGROUPS_PRELOAD-1].snapshot.key,
        firstMessages: childFirstMessages,
      );

      // Add the data for this group to the list of data
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