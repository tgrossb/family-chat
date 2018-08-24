import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class NameInput extends StatefulWidget {
  final FirebaseUser newUser;
  final Function(String) saveName;
  NameInput({@required this.newUser, @required this.saveName});

  @override
  State<StatefulWidget> createState() => new NameInputState(newUser: newUser, saveName: saveName);
}

class NameInputState extends State<NameInput> {
  FirebaseUser newUser;
  Function(String) saveName;
  NameInputState({@required this.newUser, @required this.saveName});

  String validate(String value){
    if (value.isEmpty)
      return "Please enter your name";

    final RegExp nameExp = new RegExp(r'^[A-Za-z ]+$');
    if (!nameExp.hasMatch(value))
      return "Please enter only alphabetical characters";

    return null;
  }

  @override
  Widget build(BuildContext context){
    return TextFormField(
      initialValue: newUser.displayName,
      decoration: InputDecoration(
          labelText: "Name",
          icon: Icon(Icons.person)
      ),
      validator: validate,
      onSaved: saveName,
    );
  }
}