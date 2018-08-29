import 'dart:collection';
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

    if (value.length != 0 && !(NumberTextInputFormatter.stripNumbers(value).length == 10))
      return "Enter a valid 10-digit phone number";

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
  static Queue<int> stripNumbers(String s){
    return Queue.of(s.codeUnits.where((charCode) => 47 < charCode && charCode < 58));
  }

  String mask, masker, placeHolder;
  List<String> maskList;
  int lastMask;
  int staticCounter;

  NumberTextInputFormatter({this.mask: "(xxx) xxx - xxxx",
                            this.masker: "x",
                            this.placeHolder: " "}){
    maskList = mask.split("");
    print(maskList);
    lastMask = maskList.lastIndexOf(masker);
  }

  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    Queue<int> oldNums = stripNumbers(oldValue.text);
    Queue<int> phoneNums = stripNumbers(newValue.text);
    bool adding = oldNums.length < phoneNums.length;
    bool deleting = oldNums.length > phoneNums.length;

    // 3 static movements in a row is a sign that something is being ignored
    if (oldNums.length == phoneNums.length)
      staticCounter++;
    else
      staticCounter = 0;

    // If there are 3 or more statics in a row, remove the last character from newValue if there are any
    // Also, set deleting to true and adding to false if phoneNums is not 0 after this
    if (staticCounter > 2){
      print("3 statics");
      staticCounter = 0;
      if (phoneNums.length > 0)
        phoneNums.removeLast();
      if (phoneNums.length == 0){
        adding = true;
        deleting = false;
      } else {
        adding = false;
        deleting = true;
      }
    }

    StringBuffer output = StringBuffer();

    // Stream through the mask, placing numbers in order at mask characters
    // When out of numbers, place placeHolder at that mask
    // Additionally, find the string index of the first place holder
    int nextMaskStart;
    int characterCounter = 0;

    print(adding ? "Adding" : deleting ? "Deleting" : "Static");

    for (String maskCharacter in maskList){
      if (phoneNums.isEmpty) {
        // This is when the nextMaskStart becomes relevant
        if (maskCharacter == masker) {
          // If this is a masker character, just set the selected index to here if it hasn't been set
//          nextMaskStart ?? print("Setting nextMaskStart to $characterCounter (i1)");
          nextMaskStart ??= characterCounter;
        } else if (deleting) {
          // If numbers are being subtracted, and this character is a non-masker character, set the next mask start to right before this
//          nextMaskStart ?? print("Setting nextMaskStart to $characterCounter (i2)");
          nextMaskStart ??= characterCounter;
        }
        // If numbers are being added and this character is a non-masker character, wait the next masker character (do nothing)
      }

      if (maskCharacter == masker && phoneNums.isNotEmpty)
        // If this is a mask character and there is a phone number, add the number
        output.writeCharCode(phoneNums.removeFirst());
      else if (maskCharacter == masker && phoneNums.isEmpty)
        // If this is a masker character but there are no more numbers, add a place holder
        output.write(placeHolder);
      else
        // If this is not a masker character, copy from the mask
        output.write(maskCharacter);

      characterCounter++;
    }

    // If the nextMaskStart is still null, set it to the end
    nextMaskStart ??= maskList.length;


    if (newValue.selection.baseOffset != newValue.text.length){
      print("Not on");
      int masks = 0;
      for (int c=0; c<maskList.length; c++){
        if (masks == newValue.selection.baseOffset)
          nextMaskStart = c;
        if (maskList[c] == masker)
          masks++;
      }
      // If adding, find the next non masker character
      if (adding)
        nextMaskStart = maskList.indexOf(masker, nextMaskStart);
      // If deleting, find the next non masker character backwards
      else if (deleting)
        for (; nextMaskStart>1; nextMaskStart--)
          if (maskList[nextMaskStart-1] == masker)
            break;
      print("End: $nextMaskStart ($adding, $deleting)");
    }

    return new TextEditingValue(
      text: output.toString(),
      selection: new TextSelection.collapsed(offset: nextMaskStart),
    );
  }
}