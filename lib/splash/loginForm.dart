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

class LoginForm extends StatefulWidget {
  LoginForm({Key key}): super(key: key);

  @override
  State<LoginForm> createState() => LoginFormState();
}

class LoginFormState extends State<LoginForm> {
  final _formKey = GlobalKey<FormState>();
  final focus = FocusNode();

  String _email, _password;
  bool _autovalidate = false;
  RegExp emailRegex;

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
              FocusScope.of(context).requestFocus(focus);
            },
          ),

          SizedBox(height: 16),

          TextFormField(
            focusNode: focus,
            style: TextStyle(color: Consts.TEXT_GRAY),
            decoration: InputDecoration(labelText: "Password"),
            textInputAction: TextInputAction.done,
            onFieldSubmitted: (value) => onLoginPressed(),
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
              onPressed: (){
                print("FORGOT PASSWORD!!!! Lol thats rough");
              },
              child: Text("Forgot password",
                  style: TextStyle(fontWeight: FontWeight.bold, color: Consts.BLUE)),
              padding: EdgeInsets.only(),
            ),
          ),

          SpinnerButton(
            text: Text("LOG IN", style: TextStyle(fontSize: 24, fontFamily: 'Rubik', color: Colors.white)),
            spinner: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Consts.BLUE),
            ),
            backgroundColor: Consts.GREEN,
            morphDuration: Duration(seconds: 1),
            fadeTextDuration: Duration(milliseconds: 250),
            onClick: onLoginPressed,
            padding: EdgeInsets.symmetric(horizontal: 64, vertical: 16),
            endPadding: EdgeInsets.symmetric(horizontal: 16),
          ),

          FlatButton(
            onPressed: (){
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

  void onLoginPressed(){
    if (_formKey.currentState.validate()) {
      _formKey.currentState.save();
      // Try the actual login
      login(_email, _password);
    } else
      setState(() {
        _autovalidate = true;
      });
  }

  void login(String email, String password){
    print("Successful login for $email with password '$password'");
  }
}