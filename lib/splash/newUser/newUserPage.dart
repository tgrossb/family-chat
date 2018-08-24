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
import 'package:bodt_chat/splash/newUser/nameInput.dart';
import 'package:bodt_chat/splash/newUser/emailInput.dart';
import 'package:bodt_chat/splash/newUser/phoneInput.dart';
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
  String name, email, cellPhone, homePhone, address, birthday;

  _NewUserFormState({@required this.newUser}):
      formKey = new GlobalKey<FormState>();

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

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).primaryColor,
      padding: EdgeInsets.symmetric(horizontal: 10.0),
      child: Form(
        key: formKey,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            new NameInput(newUser: newUser, saveName: (value) => name = value),
            new EmailInput(newUser: newUser, saveEmail: (value) => email = value),
            new PhoneInput(newUser: newUser, savePhone: (value) => cellPhone = value, phoneIcon: Icon(Icons.phone_android)),
            buildSubmitButton(context)
         ],
       ),
     )
    );
  }
}