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
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:bodt_chat/splash/newUser/simpleInput.dart';
import 'package:bodt_chat/splash/newUser/phoneInput.dart';
import 'package:bodt_chat/splash/newUser/simplePhoneInput.dart';
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
  RegExp emailChecker;

  _NewUserFormState({@required this.newUser}):
      formKey = new GlobalKey<FormState>(),
      emailChecker = new RegExp(r"[a-z0-9!#$%&'*+/=?^_`{|}~-]+(?:\.[a-z0-9!#$%&'*+/=?^_`{|}~-]+)*@(?:[a-z0-9](?:[a-z0-9-]*[a-z0-9])?\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?");


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

  String validateName(String value, UserParameter<String> param){
    value = value.trim();
    if (value.isEmpty)
      return "Please enter your name";

    final RegExp nameExp = new RegExp(r'^[A-Za-z ]+$');
    if (!nameExp.hasMatch(value))
      return "Please enter only alphabetical characters";

    name = param;
    return null;
  }

  String validateEmail(String value, UserParameter<String> param){
    value = value.trim();
    if (value.isEmpty)
      return "Please enter your email";

    String emailMatch = emailChecker.stringMatch(value);
    if (emailMatch == null || emailMatch.length != value.length)
      return 'Please enter a valid email';

    email.value = value;

    email = param;
    return null;
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
            new SimpleInput(
              initialValue: UserParameter<String>(name: kUSER_NAME, value: newUser.displayName),
              validate: validateName,
              icon: Icons.person,
              label: "Name",
              keyboardType: TextInputType.text,
              switchValue: true,
            ),
            new SimpleInput(
              initialValue: UserParameter<String>(name: kUSER_EMAIL, value: newUser.email),
              validate: validateEmail,
              icon: Icons.email,
              keyboardType: TextInputType.emailAddress,
              label: "Email"
            ),
            new SimplePhoneInput(
              newUser: newUser,
              savePhone: (value) => cellPhone = value,
              phoneIcon: Icon(Icons.phone_android),
              label: "Cell phone"
            ),
            new SimplePhoneInput(
                newUser: newUser,
                savePhone: (value) => homePhone = value,
                phoneIcon: Icon(Icons.phone),
                label: "Home phone"
            ),
            new SimpleInput(
              initialValue: UserParameter<String>(name: kUSER_DOB, value: ""),
              validate: (value, param){
                dob = param;
                return null;
              },
              icon: Icons.calendar_today,
              keyboardType: TextInputType.datetime,
              label: "Date of birth",
            ),
            buildSubmitButton(context)
         ],
       ),
     )
    );
  }
}