import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class EmailInput extends StatefulWidget {
  final FirebaseUser newUser;
  final Function(String) saveEmail;
  EmailInput({@required this.newUser, @required this.saveEmail});

  @override
  State<StatefulWidget> createState() => new EmailInputState(newUser: newUser, saveEmail: saveEmail);
}

class EmailInputState extends State<EmailInput> {
  FirebaseUser newUser;
  Function(String) saveEmail;
  RegExp emailChecker;

  EmailInputState({@required this.newUser, @required this.saveEmail}):
      emailChecker = new RegExp(r"[a-z0-9!#$%&'*+/=?^_`{|}~-]+(?:\.[a-z0-9!#$%&'*+/=?^_`{|}~-]+)*@(?:[a-z0-9](?:[a-z0-9-]*[a-z0-9])?\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?");

  String validate(String value){
    value = value.trim();
    if (value.length == 0)
      return "Please enter your email";

    String emailMatch = emailChecker.stringMatch(value);
    if (emailMatch == null || emailMatch.length != value.length)
      return 'Please enter a valid email';

    return null;
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      initialValue: newUser.email,
      decoration: InputDecoration(
        labelText: "Email",
        icon: Icon(Icons.email),
      ),

      onSaved: saveEmail,
      validator: validate,
    );
  }
}