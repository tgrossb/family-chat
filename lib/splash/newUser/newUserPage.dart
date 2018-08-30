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
import 'package:bodt_chat/dataUtils/dataBundles.dart';
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
  List<UserParameter<String>> params;
  List<InputFieldParams> fieldsParams;

  @override
  void initState(){
    super.initState();
    formKey = new GlobalKey<FormState>();

    MaskedTextInputFormatter cellPhoneFormatter = NewUserForm.getPhoneMask();
    MaskedTextInputFormatter homePhoneFormatter = NewUserForm.getPhoneMask();
    MaskedTextInputFormatter dobFormatter = NewUserForm.getDateMask();

    params = [
      new UserParameter<String>(name: kUSER_NAME, value: widget.newUser.displayName, private: false),
      new UserParameter<String>(name: kUSER_EMAIL, value: widget.newUser.email, private: false),
      new UserParameter<String>(name: kUSER_CELLPHONE, value: widget.newUser.phoneNumber?? "", private: true),
      new UserParameter<String>(name: kUSER_HOME_PHONE, value: "", private: true),
      new UserParameter<String>(name: kUSER_DOB, value: "", private: true)
    ];

    fieldsParams = [
      InputFieldParams(label: "Name", isRequired: true, switchValue: true, validator: Validators.validateName, icon: Icons.person,
                        keyboardType: TextInputType.text, autovalidate: true),

      InputFieldParams(label: "Email", isRequired: true, validator: Validators.validateEmail, icon: Icons.email,
                        keyboardType: TextInputType.text),

      InputFieldParams(label: "Cell phone", isRequired: true, validator: Validators.validatePhoneNumber, icon: Icons.phone_android,
                        formatters: <TextInputFormatter>[WhitelistingTextInputFormatter.digitsOnly, cellPhoneFormatter],
                        keyboardType: TextInputType.number),

      InputFieldParams(label: "Home phone", isRequired: false, validator: Validators.validatePhoneNumber, icon: Icons.phone,
                        formatters: <TextInputFormatter>[WhitelistingTextInputFormatter.digitsOnly, homePhoneFormatter],
                        keyboardType: TextInputType.number),

      InputFieldParams(label: "Date of birth", isRequired: false, validator: Validators.validateDob, icon: Icons.calendar_today,
                        formatters: <TextInputFormatter>[WhitelistingTextInputFormatter.digitsOnly, dobFormatter], useNew: true,
                        keyboardType: TextInputType.number)
    ];
  }

  Widget buildSubmitButton(BuildContext context){
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Center(
          child: new GestureDetector(
            onTap: () {
              if (formKey.currentState.validate())
                Scaffold.of(context).showSnackBar(SnackBar(content: Text('Processing Data')));
            },
            child: new Container(
              width: 100.0,
              height: 50.0,
              child: new Text("Continue", style: Theme.of(context).primaryTextTheme.subhead),
              alignment: FractionalOffset.center,
              decoration: new BoxDecoration(
                  color: Theme.of(context).primaryColor,
                  borderRadius: new BorderRadius.all(Radius.circular(25.0))
              ),
            ),
          )
      ),
    );
  }

  void requestNextFocus(int c) {
    fieldsParams[c].focusNode.unfocus();
    if (c+1 < fieldsParams.length)
      FocusScope.of(context).requestFocus(fieldsParams[c+1].focusNode);
  }
  
  Widget buildPublicLabel(BuildContext context){
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: <Widget>[
       Padding(
         padding: EdgeInsets.symmetric(horizontal: 24.0, vertical: 4.0),
         child: InkWell(
           onTap: showInfo,
           child: Icon(
             Icons.info_outline,
             color: Theme.of(context).primaryColor,
           ),
         ),
       )
      ],
    );
/*
Padding(
          padding: EdgeInsets.only(right: 0.0),
          child:
        )
*/
  }
  
  Widget buildField(BuildContext context, int c){
    InputFieldParams fieldParams = fieldsParams[c];
    return SimpleInput.fromParams(
      initialValue: params[c],
      validate: (value, param, isRequired, label) =>
            fieldParams.validator(value, param, isRequired, label, (param) => params[c] = param),
      requestNextFocus: requestNextFocus,
      location: c,
      params: fieldParams
    );
  }

  List<Widget> buildFields(BuildContext context){
    List<Widget> fields = [];
    for (int c=0; c<fieldsParams.length; c++)
      fields.add(buildField(context, c));
    fields.add(Padding(
      padding: EdgeInsets.only(left: 42.0),
      child: Text("* Required", style: Theme.of(context).inputDecorationTheme.labelStyle),
    ));
    return fields;
  }

  List<Widget> buildForm(BuildContext context){
    List<Widget> widgets = [];
    widgets.add(buildPublicLabel(context));
    widgets.addAll(buildFields(context));
    widgets.add(buildSubmitButton(context));
    return widgets;
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
          children: buildForm(context),
       ),
     )
    );
  }
}