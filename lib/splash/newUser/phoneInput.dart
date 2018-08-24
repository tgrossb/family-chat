import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:bodt_chat/splash/newUser/countrySelector.dart';

class PhoneInput extends StatefulWidget {
  final FirebaseUser newUser;
  final Function(String) savePhone;
  final Icon phoneIcon;
  PhoneInput({@required this.newUser, @required this.savePhone, @required this.phoneIcon});

  @override
  State<StatefulWidget> createState() => new PhoneInputState(newUser: newUser, savePhone: savePhone, phoneIcon: phoneIcon);
}

class PhoneInputState extends State<PhoneInput> {
  FirebaseUser newUser;
  Function(String) savePhone;
  Icon phoneIcon;
  NumberTextInputFormatter numberFormatter;
  RegExp numberMatcher;
  String phoneCode;

  PhoneInputState({@required this.newUser, @required this.savePhone, @required this.phoneIcon}):
      numberFormatter = new NumberTextInputFormatter(),
      numberMatcher = new RegExp(r"^\(\d\d\d\) \d\d\d\-\d\d\d\d$");

  String validatePhoneNumber(String value){
    value = value.trim();
    if (value.length == 0)
      return "Enter your phone number";

    if (!numberMatcher.hasMatch(value))
      return "";

    return null;
  }

  @override
  Widget build(BuildContext context){
    return Row(
//      mainAxisAlignment: MainAxisAlignment.start,
//      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        new CountrySelector(saveCountry: (value) => phoneCode = value),
        Flexible(
          child: TextFormField(
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
                labelText: ""
            ),

            onSaved: (value) => savePhone(phoneCode + " " + value),
            validator: validatePhoneNumber,
            inputFormatters: <TextInputFormatter> [
              WhitelistingTextInputFormatter.digitsOnly,
              numberFormatter,
            ],
          ),
        )
      ],
    );
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