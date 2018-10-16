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

import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/animation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:bodt_chat/groupsList/groupsListScreen.dart';
import 'package:bodt_chat/loaders/dotMatrixLoader/dotMatrixLoaderWidget.dart';
import 'package:bodt_chat/widgetUtils/animatedLoadingButton.dart';
//import 'package:bodt_chat/splash/signInButton.dart';
import 'package:bodt_chat/splash/newUser/newUserPage.dart';
import 'package:bodt_chat/widgetUtils/routes.dart';
import 'package:bodt_chat/constants.dart';
import 'package:bodt_chat/dataUtils/database.dart';
//import 'package:bodt_chat/loaderTest.dart';


class SplashPage extends StatefulWidget {
  @override
  State createState() => new _SplashPageState();
}

class _SplashPageState extends State<SplashPage> with TickerProviderStateMixin {
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  final GoogleSignIn gSignIn = new GoogleSignIn();
  final GlobalKey<ScaffoldState> scaffoldKey = new GlobalKey<ScaffoldState>();
  final GlobalKey buttonKey = new GlobalKey();
//  bool loading = false, startFinishFlag = false, finishingStarted = false, finished = false;

//  AnimationController loadingAnimationController, signInButtonToLoadingController;
//  Animation<double> loadingAnimation;
//  int animationCount = 0;

  @override
  void initState(){
    super.initState();

    // TODO: Implement full silent sign in
  }

  // First, attempt a silent sign in
  // If that is successful, start loading from this
  // Otherwise, try a prompted sign in
  void startSignIn() async {
    // Try out a silent sign in
    FirebaseUser user;
//    FirebaseUser user = await attemptCheckedSignIn(attemptSilentSignIn);

    // Begin loading information if the silent sign in was successful
    if (user != null)
      await loadInformation(user);

    // If that fails, attempt a full on sign in
    user = await attemptCheckedSignIn(attemptSignIn);

    // Again, begin loading information if that sign in was successful
    if (user != null)
      await loadInformation(user);

    if (user == null) {
      // If neither of those worked, show a snack bar error and give up
      SnackBar snackBar = new SnackBar(
          content: new Text("Nothing works, oh well"));
      scaffoldKey.currentState.showSnackBar(snackBar);
      (buttonKey.currentWidget as AnimatedLoadingButton).finishAnimation();
    }
  }

  Future<FirebaseUser> attemptCheckedSignIn(Function signInMethod) async {
    FirebaseUser user;
    try {
      user = await signInMethod();
      print("No errors");
    } on PlatformException catch(e){
      String snackBarMessage = "Error: " + e.code;
      if (e.code == "NETWORK_ERROR"){
        // Show connection error dialog, but for now, just add a snack bar
        snackBarMessage = "Network error signing you in";
      } else {
        snackBarMessage = "${e.code} (Unknown)";
      }

      SnackBar snackBar = new SnackBar(content: new Text(snackBarMessage));
      scaffoldKey.currentState.showSnackBar(snackBar);

      // If an error occurs, end the button animation
      (buttonKey.currentWidget as AnimatedLoadingButton).finishAnimation();
      return null;
    }

    return user;
  }

  Future<void> loadInformation(FirebaseUser user) async {
    print("Loading information for ${user.uid}");
    // Check if this is a new user
    if (!(await DatabaseReader.userExists()))
      // If it is a new user, register them
      await registerNewUser(user);

    // Load all user uids
    await DatabaseReader.loadUserUids();
    print("Successfully loaded user uids");

    print(Database.userUids);

    // Load all user data (public)
    await DatabaseReader.loadUsers(user.uid);
    print("Successfully loaded user data");

    // Load all group names
    await DatabaseReader.loadGroupNames();
    print("Successfully loaded group names");

    // Load all group data
    await DatabaseReader.loadGroups();
    print("Successfully loaded group data");

    // If everything went well, finish the animation and navigate to the groups screen when that is done
//    await (buttonKey.currentWidget as AnimatedLoadingButton).finishAnimation();
//    navigateToGroups();
  }

  Future<int> registerNewUser(FirebaseUser newUser) async {
    print("Needs to be registered");

    if (newUser == null) {
      print("Null new user");
      scaffoldKey.currentState.showSnackBar(
          SnackBar(content: Text("Null newUser")));
    }

    await Navigator.of(context).push(
        new SlideLeftRoute(widget: new NewUserPage(newUser: newUser)));
//        ModalRoute.withName("/"));

    return 0;
  }

  void navigateToGroups(){
    Navigator.of(context).pushReplacement(new InstantRoute(widget: new GroupsListScreen()));
  }

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
    return new Scaffold(
      key: scaffoldKey,
      body: new Container(
        color: Theme.of(context).accentColor,
        child: new Center(
          child: AnimatedLoadingButton(
            key: buttonKey,
            text: Text("Sign in with Google", style: Theme.of(context).primaryTextTheme.title),
            loaderAnimation: DotMatrixLoaderWidget(key: GlobalKey()),
            backgroundColor: Theme.of(context).primaryColor,
            onClick: startSignIn,
          )
        ),
      ),
    );
  }
}