import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class EmailInput extends StatefulWidget {
  final FirebaseUser newUser;
  final Function(String) saveEmail;
  EmailInput({@required this.newUser, @required this.saveEmail});

  @override
  State<StatefulWidget> createState() => new EmailInputState(newUser: newUser, saveEmail: saveEmail);
}

class EmailInputState extends State<EmailInput> with SingleTickerProviderStateMixin {
  FirebaseUser newUser;
  Function(String) saveEmail;
  RegExp emailChecker;
  FocusNode node;
  AnimationController backgroundController;
  Animation<double> background;

  EmailInputState({@required this.newUser, @required this.saveEmail}):
      emailChecker = new RegExp(r"[a-z0-9!#$%&'*+/=?^_`{|}~-]+(?:\.[a-z0-9!#$%&'*+/=?^_`{|}~-]+)*@(?:[a-z0-9](?:[a-z0-9-]*[a-z0-9])?\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?")
  {
    node = FocusNode();
  }

  @override
  void initState(){
    super.initState();

    Tween<double> opacityTween = Tween(begin: 0.0, end: 1.0);
    backgroundController = AnimationController(vsync: this, duration: Duration(milliseconds: 200));
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
    return AnimatedBuilder(
      builder: buildFormAnimation,
      animation: backgroundController,
    );
  }

  Widget buildFormAnimation(BuildContext context, Widget child){
//    Color goalColor = Theme.of(context).inputDecorationTheme.fillColor;
//    Color thisCol = goalColor.withOpacity(goalColor.opacity * background.value);
//    print(thisCol);
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: <Widget>[
          Padding(
            padding: EdgeInsets.only(right: 16.0),
            child: Icon(
                Icons.email,
//                color: Theme.of(context).inputDecorationTheme.labelStyle.color
            ),
          ),
          Flexible(
            child: TextFormField(
              initialValue: newUser.email,
              focusNode: node,
              decoration: InputDecoration(
                labelText: "Email",
//                border: InputBorder.
              ),

              onSaved: saveEmail,
              validator: validate,
            ),
          ),
        ],
      )
    );
  }
}