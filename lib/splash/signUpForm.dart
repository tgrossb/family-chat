/**
 * An encapsulation of the login form with all of its graphics and layout.
 *
 * This widget is the email and password form fields, as well as the forgot password,
 * sign up, and login buttons, along with the validation logic for the email.  Pretty simple.
 *
 * Written by: Theo Grossberndt
 */

import 'package:flutter/material.dart';
import 'package:hermes/consts.dart';
import 'package:hermes/widgets/spinnerButton.dart';
import 'package:hermes/widgets/checkProgressIndicator.dart';
import 'package:hermes/authentication.dart';
import 'package:hermes/user.dart';
import 'dart:async';

class SignUpForm extends StatefulWidget {
  final Auth auth;
  SignUpForm({Key key, @required this.auth}): super(key: key);

  @override
  State<SignUpForm> createState() => SignUpFormState();
}

class SignUpFormState extends State<SignUpForm> {
  final _formKey = GlobalKey<FormState>();
  final passwordFocus = FocusNode();
  final confirmFocus = FocusNode();
  final confirmController = TextEditingController();
  final StreamController<int> tapInitiator = StreamController();
  final StreamController<int> progressFinisher = StreamController();

  String _email, _password;
  bool _autovalidate = false;
  RegExp emailRegex;

  bool _signingUp = false;

  SignUpFormState(){
    Pattern emailPattern = r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
    emailRegex = new RegExp(emailPattern);
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      autovalidate: _autovalidate,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          TextFormField(
            enabled: !_signingUp,
            style: TextStyle(color: Consts.TEXT_GRAY),
            decoration: InputDecoration(labelText: "Email"),
            textInputAction: TextInputAction.next,
            keyboardType: TextInputType.emailAddress,
            validator: (value){
              if (value.isEmpty)
                return "Please enter your email";
              if (!emailRegex.hasMatch(value))
                return "Hmm that doesn't look like an email";
              return null;
            },
            onSaved: (value){
              _email = value;
            },
            onFieldSubmitted: (value){
              FocusScope.of(context).requestFocus(passwordFocus);
            },
          ),

          SizedBox(height: 16),

          TextFormField(
            enabled: !_signingUp,
            focusNode: passwordFocus,
            style: TextStyle(color: Consts.TEXT_GRAY),
            decoration: InputDecoration(labelText: "Password"),
            textInputAction: TextInputAction.next,
            onFieldSubmitted: (value){
              FocusScope.of(context).requestFocus(confirmFocus);
            },
            keyboardType: TextInputType.text,
            obscureText: true,
            validator: (value){
              if (value.isEmpty)
                return "Please enter a password";
              return null;
            },
            onSaved: (value){
              _password = value;
            },
          ),

          SizedBox(height: 16),

          TextFormField(
            enabled: !_signingUp,
            focusNode: confirmFocus,
            controller: confirmController,
            style: TextStyle(color: Consts.TEXT_GRAY),
            decoration: InputDecoration(labelText: "Confirm Password"),
            textInputAction: TextInputAction.next,
            onFieldSubmitted: (value){
              tapInitiator.add(1);
            },
            keyboardType: TextInputType.text,
            obscureText: true,
            validator: (value){
              if (value.isEmpty)
                return "Please confirm your password";
              if (value != _password)
                return "It looks like this doesn't match your password";
              return null;
            },
          ),

          SizedBox(height: 16),

          SpinnerButton(
            text: Text("SIGN UP", style: TextStyle(fontSize: 24, fontFamily: 'Rubik', color: Colors.white)),
            spinner: CheckProgressIndicator(
              color: Consts.BLUE,
              strokeWidth: 2,
              finish: progressFinisher.stream,
            ),
            backgroundColor: Consts.GREEN,
            morphDuration: Duration(seconds: 1),
            fadeTextDuration: Duration(milliseconds: 250),
            shouldAnimate: shouldAnimate,
            onClick: attemptSignUp,
            padding: EdgeInsets.symmetric(horizontal: 64, vertical: 16),
            endPadding: EdgeInsets.symmetric(horizontal: 16),
            tapInitiator: tapInitiator.stream,
          ),
        ],
      ),
    );
  }

  // Validates the form
  bool shouldAnimate(){
    setState(() {
      _autovalidate = true;
    });

    if (_formKey.currentState.validate()){
      _formKey.currentState.save();
      return true;
    }

    return false;
  }

  // The entry point for signing up from the button
  Future<bool> attemptSignUp(bool valid) async {
    if (valid) {
      setState((){
        _signingUp = true;
      });

      bool success = await signUp(_email, _password);
      print("Signing up for user '$_email' with password '$_password' was ${success ? "successful" : "unsuccessful"}");

      if (!success) {
        setState(() {
          _signingUp = false;
        });

        FocusScope.of(context).requestFocus(confirmFocus);
        confirmController.clear();
      } else
        progressFinisher.add(1);

      return success;
    }
    return false;
  }
  
  Future<bool> signUp(String email, String password) async {
    User user = await widget.auth.signUp(email, password);
    if (user.isValid()){
      return true;
    }

    return false;
  }

  @override
  void dispose() {
    tapInitiator.close();
    progressFinisher.close();
    super.dispose();
  }
}