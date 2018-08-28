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
  final bool isRequired;
  SimplePhoneInput({@required this.newUser, @required this.savePhone, @required this.phoneIcon, @required this.label, this.isRequired: false});

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
    if (value.length == 0 && widget.isRequired)
      return "Enter your phone number";

    if (value.length != 0 && !numberMatcher.hasMatch(value))
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
  static List<int> stripNumbers(String s){
    return s.codeUnits.where((charCode) => 47 < charCode && charCode < 58).toList();
  }

  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    List<int> phoneNums = stripNumbers(newValue.text);
    int phoneCount = phoneNums.length;
    List<String> output = ["(", " ", " ", " ", ") ", " ", " ", " ", " - ", " ", " ", " ", " "];
    int outputIndex = 1;
    for (int phoneIndex=0; phoneIndex<phoneCount; phoneIndex++){
      outputIndex = phoneIndex + (phoneIndex > 2 ? (phoneIndex > 5 ? 3 : 2) : 1);
      output[outputIndex] = String.fromCharCode(phoneNums[phoneIndex]);
    }

    // Sum the length of the output up to outputIndex
    int outputCharIndex = 0;
    for (int c=0; c<outputIndex; c++)
      outputCharIndex += output[c].length;

    return new TextEditingValue(
      text: output.join(),
      selection: new TextSelection.collapsed(offset: outputCharIndex+1),
    );
  }
}