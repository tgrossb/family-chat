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
import 'package:bodt_chat/splash/newUser/inputs/simpleInput.dart';
import 'package:bodt_chat/splash/newUser/inputs/phoneInput.dart';
import 'package:bodt_chat/splash/newUser/inputs/simplePhoneInput.dart';
import 'package:bodt_chat/splash/newUser/inputs/simpleDateInput.dart';
import 'package:bodt_chat/widgetUtils/validators.dart';
import 'package:bodt_chat/widgetUtils/maskedTextInputFormatter.dart';
import 'package:bodt_chat/constants.dart';
import 'package:bodt_chat/dataUtils/user.dart';
import 'package:bodt_chat/dataUtils/database.dart';


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
  static String phoneMask = "(xxx) xxx - xxxx";
  static String phoneMasker = "x";
  static RegExp phoneMaskable = new RegExp(r"[0-9]");

  static String dateMask = "xx / xx / xx";
  static String dateMasker = "x";
  // TODO: By-character regexing in masker
  static RegExp dateMaskable = new RegExp(r"[0-9]");

  static MaskedTextInputFormatter getPhoneMask() =>
    new MaskedTextInputFormatter(mask: phoneMask, masker: phoneMasker, maskedValueMatcher: phoneMaskable);

  static MaskedTextInputFormatter getDateMask() =>
    new MaskedTextInputFormatter(mask: dateMask, masker: dateMasker, maskedValueMatcher: dateMaskable);

  NewUserForm({@required this.newUser});

  final FirebaseUser newUser;

  @override
  State createState() => new _NewUserFormState();
}

class _NewUserFormState extends State<NewUserForm> {
  GlobalKey<FormState> formKey;
  String address;
  UserParameter<String> name, email, cellPhone, homePhone, dob;
  MaskedTextInputFormatter cellPhoneFormatter, homePhoneFormatter, dobFormatter;
  List<FocusNode> focusNodes;

  @override
  void initState(){
    super.initState();
    formKey = new GlobalKey<FormState>();

    name = new UserParameter<String>(name: kUSER_NAME, value: widget.newUser.displayName, private: false);
    email = new UserParameter<String>(name: kUSER_EMAIL, value: widget.newUser.email, private: false);
    cellPhone = new UserParameter<String>(name: kUSER_CELLPHONE, value: widget.newUser.phoneNumber?? "", private: true);
    homePhone = new UserParameter<String>(name: kUSER_HOME_PHONE, value: "", private: true);
    dob = new UserParameter<String>(name: kUSER_DOB, value: "", private: true);

    cellPhoneFormatter = NewUserForm.getPhoneMask();
    homePhoneFormatter = NewUserForm.getPhoneMask();
    dobFormatter = NewUserForm.getDateMask();

    focusNodes = List<FocusNode>(5);
    for (int c=0; c<focusNodes.length; c++)
      focusNodes[c] = new FocusNode();
  }

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

  void requestNextFocus(int c) {
    focusNodes[c].unfocus();
    if (c+1 < focusNodes.length)
      FocusScope.of(context).requestFocus(focusNodes[c+1]);
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
              validate: (value, param, isRequired, label) =>
                  Validators.validateName(value, param, isRequired, label, (param) => name = param),
              icon: Icons.person,
              label: "Name",
              keyboardType: TextInputType.text,
              switchValue: true,
              isRequired: true,
              autovalidate: true,
              focusNode: focusNodes[0],
              focusIndex: 0,
              requestNextFocus: requestNextFocus,
            ),
            new SimpleInput(
              initialValue: email,
              validate: (value, param, isRequired, label) =>
                  Validators.validateEmail(value, param, isRequired, label, (param) => email = param),
              icon: Icons.email,
              keyboardType: TextInputType.emailAddress,
              label: "Email",
              focusNode: focusNodes[1],
              focusIndex: 1,
              requestNextFocus: requestNextFocus,
            ),
            new SimpleInput(
              initialValue: cellPhone,
              validate: (value, param, isRequired, label) =>
                  Validators.validatePhoneNumber(value, param, isRequired, label, (param) => cellPhone = param),
              icon: Icons.phone_android,
              label: "Cell phone",
              keyboardType: TextInputType.number,
              isRequired: true,
              inputFormatters: <TextInputFormatter>[
                WhitelistingTextInputFormatter.digitsOnly,
                cellPhoneFormatter
              ],
              focusNode: focusNodes[2],
              focusIndex: 2,
              requestNextFocus: requestNextFocus,
            ),
            new SimpleInput(
              initialValue: cellPhone,
              validate: (value, param, isRequired, label) =>
                  Validators.validatePhoneNumber(value, param, isRequired, label, (param) => homePhone = param),
              icon: Icons.phone,
              label: "Home phone",
              keyboardType: TextInputType.number,
              isRequired: true,
              inputFormatters: <TextInputFormatter>[
                WhitelistingTextInputFormatter.digitsOnly,
                homePhoneFormatter
              ],
              focusNode: focusNodes[3],
              focusIndex: 3,
              requestNextFocus: requestNextFocus,
            ),
            new SimpleInput(
              initialValue: dob,
              validate: (value, param, isRequired, label) =>
                Validators.validateDob(value, param, isRequired, label, (param) => dob = param),
              icon: Icons.calendar_today,
              label: "Date of birth",
              keyboardType: TextInputType.number,
              inputFormatters: <TextInputFormatter>[
                WhitelistingTextInputFormatter.digitsOnly,
                dobFormatter
              ],
              focusNode: focusNodes[4],
              focusIndex: 4,
              requestNextFocus: requestNextFocus,
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