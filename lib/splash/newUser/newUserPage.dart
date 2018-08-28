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
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:bodt_chat/splash/newUser/simpleInput.dart';
import 'package:bodt_chat/splash/newUser/phoneInput.dart';
import 'package:bodt_chat/splash/newUser/simplePhoneInput.dart';
import 'package:bodt_chat/splash/newUser/simpleDateInput.dart';
import 'package:bodt_chat/splash/newUser/validators.dart';
import 'package:bodt_chat/constants.dart';
import 'package:bodt_chat/user.dart';
import 'package:bodt_chat/database.dart';


class NewUserPage extends StatelessWidget {
  NewUserPage({@required this.newUser});

  final FirebaseUser newUser;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: new NewUserForm(newUser: newUser),
    );
  }
}

class NewUserForm extends StatefulWidget {
  NewUserForm({@required this.newUser});

  final FirebaseUser newUser;

  @override
  State createState() => new _NewUserFormState(newUser: newUser);
}

class _NewUserFormState extends State<NewUserForm> {
  FirebaseUser newUser;
  GlobalKey<FormState> formKey;
  String address;
  UserParameter<String> name, email, cellPhone, homePhone, dob;

  _NewUserFormState({@required this.newUser}):
      formKey = new GlobalKey<FormState>(),
      name = new UserParameter<String>(name: kUSER_NAME, value: newUser.displayName, private: false),
      email = new UserParameter<String>(name: kUSER_EMAIL, value: newUser.email, private: false),
      cellPhone = new UserParameter<String>(name: kUSER_CELLPHONE, value: newUser.phoneNumber?? "", private: true),
      homePhone = new UserParameter<String>(name: kUSER_HOME_PHONE, value: "", private: true),
      dob = new UserParameter<String>(name: kUSER_DOB, value: "", private: true);


  List<Widget> buildForm(){
    return [
      TextFormField(
        validator: (value){
          if (value.isEmpty)
            return "Please enter your name";
        },
      ),

      Center(
        child: RaisedButton(
          child: Text("Submit"),
          onPressed: (){
            if (formKey.currentState.validate())
              Scaffold.of(context).showSnackBar(SnackBar(content: Text('Processing data')));
          }
        ),
      )
    ];
  }

  Widget buildSubmitButton(BuildContext context){
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Center(
          child: RaisedButton(
            onPressed: () {
              // Validate will return true if the form is valid, or false if
              // the form is invalid.
              if (formKey.currentState.validate()) {
                // If the form is valid, we want to show a Snackbar
                Scaffold
                    .of(context)
                    .showSnackBar(SnackBar(content: Text('Processing Data')));
              }
            },
            child: Text('Submit'),
          )
      ),
    );
  }

  Future<Null> showInfo() async {
    await showDialog<Null>(
        context: context,
        builder: (BuildContext context) {
          return new SimpleDialog(
            title: const Text('Public/Private Data'),
            children: <Widget>[
              new Text("Welcome")
            ],
          );
        }
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).accentColor,
      padding: EdgeInsets.symmetric(horizontal: 10.0),
      child: Form(
        key: formKey,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            new Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                new FlatButton(
                  padding: EdgeInsets.only(right: 0.0),
                  onPressed: showInfo,
                  child: new Row(
                    children: <Widget>[
                      Text("Public"),
                      Padding(
                        padding: EdgeInsets.only(left: 4.0),
                        child: Icon(Icons.info_outline),
                      )
                    ],
                  )
                ),
              ],
            ),
            new SimpleInput(
              initialValue: name,
              validate: (value, param) => Validators.validateName(value, param, (param) => name = param),
              icon: Icons.person,
              label: "* Name",
              keyboardType: TextInputType.text,
              switchValue: true,
              isRequired: true,
              autovalidate: true,
            ),
            new SimpleInput(
              initialValue: email,
              validate: (value, param) => Validators.validateEmail(value, param, (param) => email = param),
              icon: Icons.email,
              keyboardType: TextInputType.emailAddress,
              label: "* Email",
            ),
            new SimplePhoneInput(
              newUser: newUser,
              savePhone: (value) => cellPhone = value,
              phoneIcon: Icon(Icons.phone_android),
              label: "* Cell phone",
              isRequired: true,
            ),
            new SimplePhoneInput(
                newUser: newUser,
                savePhone: (value) => homePhone = value,
                phoneIcon: Icon(Icons.phone),
                label: "Home phone"
            ),
            new SimpleDateInput(
              initialValue: dob,
              validate: (value, param) => Validators.validateDob(value, param, (param) => dob = param),
              icon: Icons.calendar_today,
              keyboardType: TextInputType.datetime,
              label: "Date of birth",
            ),
            Padding(
              padding: EdgeInsets.only(left: 42.0),
              child: Text("* Required", style: Theme.of(context).inputDecorationTheme.labelStyle),
            ),
            buildSubmitButton(context)
         ],
       ),
     )
    );
  }
}