import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:bodt_chat/splash/newUser/countrySelector.dart';
import 'package:bodt_chat/user.dart';
import 'package:bodt_chat/constants.dart';

class SimplePhoneInput extends StatefulWidget {
  final FirebaseUser newUser;
  final Function(UserParameter<String>) savePhone;
  final Icon phoneIcon;
  final String label;
  SimplePhoneInput({@required this.newUser, @required this.savePhone, @required this.phoneIcon, @required this.label});

  @override
  State<StatefulWidget> createState() => new SimplePhoneInputState(newUser: newUser, savePhone: savePhone, phoneIcon: phoneIcon);
}

class SimplePhoneInputState extends State<SimplePhoneInput> with SingleTickerProviderStateMixin {
  FirebaseUser newUser;
  Function(UserParameter<String>) savePhone;
  UserParameter<String> phone;

  Icon phoneIcon;
  NumberTextInputFormatter numberFormatter;
  RegExp numberMatcher;

  FocusNode node;
  AnimationController backgroundController;
  Animation<double> background;

  SimplePhoneInputState({@required this.newUser, @required this.savePhone, @required this.phoneIcon}):
        numberFormatter = new NumberTextInputFormatter(),
        numberMatcher = new RegExp(r"^\(\d\d\d\) \d\d\d\-\d\d\d\d$"),
        node = new FocusNode(),
        phone = new UserParameter(name: kUSER_CELLPHONE, value: "");

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

  String validatePhoneNumber(String value){
    value = value.trim();
    if (value.length == 0)
      return "Enter your phone number";

    if (!numberMatcher.hasMatch(value))
      return "";

    savePhone(phone);
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
                  phoneIcon.icon,
                  color: iconColor
              ),
            ),
            Flexible(
              child: TextFormField(
                keyboardType: TextInputType.number,
                focusNode: node,
                decoration: InputDecoration(
                  labelText: widget.label,
                  suffixIcon: Switch(
                    value: !phone.private,
                    onChanged: (value) =>
                      setState(() {
                        phone.setPrivate(!value);
                      }),
                    activeColor: Theme.of(context).primaryColor,
                  ),
                  fillColor: thisCol,
                  border: OutlineInputBorder()
                ),

                onSaved: (value) => phone.value = value,
                validator: validatePhoneNumber,
                inputFormatters: <TextInputFormatter> [
                  WhitelistingTextInputFormatter.digitsOnly,
                  numberFormatter,
                ],
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

class NumberTextInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    final int newTextLength = newValue.text.length;
    int selectionIndex = newValue.selection.end;
    int usedSubstringIndex = 0;
    final StringBuffer newText = new StringBuffer();
    if (newTextLength >= 1) {
      newText.write('(');
      if (newValue.selection.end >= 1)
        selectionIndex++;
    }
    if (newTextLength >= 4) {
      newText.write(newValue.text.substring(0, usedSubstringIndex = 3) + ') ');
      if (newValue.selection.end >= 3)
        selectionIndex += 2;
    }
    if (newTextLength >= 7) {
      newText.write(newValue.text.substring(3, usedSubstringIndex = 6) + '-');
      if (newValue.selection.end >= 6)
        selectionIndex++;
    }
    if (newTextLength >= 11) {
      newText.write(newValue.text.substring(6, usedSubstringIndex = 10) + ' ');
      if (newValue.selection.end >= 10)
        selectionIndex++;
    }
    // Dump the rest.
    if (newTextLength >= usedSubstringIndex)
      newText.write(newValue.text.substring(usedSubstringIndex));
    return new TextEditingValue(
      text: newText.toString(),
      selection: new TextSelection.collapsed(offset: selectionIndex),
    );
  }
}