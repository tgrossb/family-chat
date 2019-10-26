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
import 'dart:async';

class LoginForm extends StatefulWidget {
  LoginForm({Key key}): super(key: key);

  @override
  State<LoginForm> createState() => LoginFormState();
}

class LoginFormState extends State<LoginForm> {
  final _formKey = GlobalKey<FormState>();
  final passwordFocus = FocusNode();
  final passwordController = TextEditingController();
  final StreamController<int> tapInitiator = StreamController();
  final StreamController<int> progressFinisher = StreamController();

  String _email, _password;
  bool _autovalidate = false;
  RegExp emailRegex;

  bool _loggingIn = false;

  LoginFormState(){
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
            enabled: !_loggingIn,
            style: TextStyle(color: Consts.TEXT_GRAY),
            decoration: InputDecoration(labelText: "Email"),
            textInputAction: TextInputAction.next,
            keyboardType: TextInputType.emailAddress,
            validator: (value){
              if (value.isEmpty)
                return "Please enter your email";
              if (!emailRegex.hasMatch(value))
                return "Please enter a valid email";
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
            enabled: !_loggingIn,
            focusNode: passwordFocus,
            controller: passwordController,
            style: TextStyle(color: Consts.TEXT_GRAY),
            decoration: InputDecoration(labelText: "Password"),
            textInputAction: TextInputAction.done,
            onFieldSubmitted: (value){
              tapInitiator.add(1);
            },
            keyboardType: TextInputType.text,
            obscureText: true,
            validator: (value){
              if (value.isEmpty)
                return "Please enter your password";
              return null;
            },
            onSaved: (value){
              _password = value;
            },
          ),

          Align(
            alignment: Alignment.centerRight,
            child: FlatButton(
              onPressed: _loggingIn ? null : (){
                print("FORGOT PASSWORD!!!! Lol thats rough");
              },
              child: Text("Forgot password",
                  style: TextStyle(fontWeight: FontWeight.bold, color: Consts.BLUE)),
              padding: EdgeInsets.only(),
            ),
          ),

          SpinnerButton(
            text: Text("LOG IN", style: TextStyle(fontSize: 24, fontFamily: 'Rubik', color: Colors.white)),
            spinner: CheckProgressIndicator(
              color: Consts.BLUE,
              strokeWidth: 2,
              finish: progressFinisher.stream,
            ),
            backgroundColor: Consts.GREEN,
            morphDuration: Duration(seconds: 1),
            fadeTextDuration: Duration(milliseconds: 250),
            shouldAnimate: shouldAnimate,
            onClick: attemptLogin,
            padding: EdgeInsets.symmetric(horizontal: 64, vertical: 16),
            endPadding: EdgeInsets.symmetric(horizontal: 16),
            tapInitiator: tapInitiator.stream,
          ),

          FlatButton(
            onPressed: _loggingIn ? null : (){
              print("Bro just already be signed up");
            },
            child: RichText(
              text: TextSpan(
                  style: TextStyle(color: Consts.BLUE),
                  children: <TextSpan>[
                    new TextSpan(text: "Don't have an account yet? "),
                    new TextSpan(text: "Sign Up!", style: TextStyle(fontWeight: FontWeight.bold))
                  ]
              ),
            ),
            padding: EdgeInsets.only(),
          )
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

  // The entry point for logging in from the button
  Future<bool> attemptLogin(bool valid) async {
    if (valid) {
      setState((){
        _loggingIn = true;
      });

      bool success = await login(_email, _password);
      print("Login for user '$_email' with password '$_password' was ${success ? "successful" : "unsuccessful"}");

      if (!success) {
        setState(() {
          _loggingIn = false;
        });

        FocusScope.of(context).requestFocus(passwordFocus);
        passwordController.clear();
      } else
        progressFinisher.add(1);

      return success;
    }
    return false;
  }
  
  Future<bool> login(String email, String password) async {
    await Future.delayed(Duration(seconds: 2));
    return email == "tgrossb87@gmail.com" && password == "password";
  }

  @override
  void dispose() {
    tapInitiator.close();
    progressFinisher.close();
    super.dispose();
  }
}