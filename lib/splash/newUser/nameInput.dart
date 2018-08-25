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
  FocusNode focus;
  bool focused;

  NameInputState({@required this.newUser, @required this.saveName}):
      focus = new FocusNode();

  @override
  void initState(){
    super.initState();
    focus.addListener(() => setState((){}));
  }

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
    return Padding(
        padding: EdgeInsets.symmetric(vertical: 8.0),
        child: Row(
          children: <Widget>[
            Padding(
              padding: EdgeInsets.only(right: 16.0),
              child: Icon(
                  Icons.person,
//                  color: Theme.of(context).inputDecorationTheme.labelStyle.color
              ),
            ),
            Flexible(
              child: TextFormField(
                initialValue: newUser.displayName,
                focusNode: focus,
                decoration: InputDecoration(
                    labelText: "Name",
                    filled: focus.hasFocus,
                    border: OutlineInputBorder()
                ),
                validator: validate,
                onSaved: saveName,
              ),
            ),
          ],
        )
    );
  }

  @override
  void dispose() {
    focus.dispose();
    super.dispose();
  }
}