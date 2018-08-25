import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:bodt_chat/constants.dart';

class NameInput extends StatefulWidget {
  final FirebaseUser newUser;
  final Function(String) saveName;
  NameInput({@required this.newUser, @required this.saveName});

  @override
  State<StatefulWidget> createState() => new NameInputState(newUser: newUser, saveName: saveName);
}

class NameInputState extends State<NameInput> with SingleTickerProviderStateMixin {
  FirebaseUser newUser;
  Function(String) saveName;
  FocusNode node;
  AnimationController backgroundController;
  Animation<double> background;

  NameInputState({@required this.newUser, @required this.saveName}):
        node = FocusNode();

  @override
  void initState(){
    super.initState();

    Tween<double> opacityTween = Tween(begin: 0.0, end: 1.0);
    backgroundController = AnimationController(vsync: this, duration: Duration(milliseconds: kSELECT_FIELD_SHADE));
    background = opacityTween.animate(backgroundController);

    node.addListener((){
      setState(() {
        if (node.hasFocus)
          backgroundController.forward(from: 0.0);
        else
          backgroundController.reverse(from: 1.0);
      });
    });
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
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      builder: buildFormAnimation,
      animation: backgroundController,
    );
  }

  Widget buildFormAnimation(BuildContext context, Widget child){
    Color goalColor = Theme.of(context).inputDecorationTheme.fillColor;
    Color thisCol = goalColor.withOpacity(goalColor.opacity * background.value);

    Color iconBaseColor = Theme.of(context).inputDecorationTheme.labelStyle.color;
    Color iconColor = iconBaseColor.withOpacity(iconBaseColor.opacity - 2*goalColor.opacity * background.value);

    return Padding(
        padding: EdgeInsets.symmetric(vertical: 8.0),
        child: Row(
          children: <Widget>[
            Padding(
              padding: EdgeInsets.only(right: 16.0),
              child: Icon(
                Icons.person,
                color: iconColor
              ),
            ),
            Flexible(
              child: TextFormField(
                initialValue: newUser.displayName,
                focusNode: node,
                decoration: InputDecoration(
                    labelText: "Name",
                    fillColor: thisCol,
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
    node.dispose();
    super.dispose();
  }
}