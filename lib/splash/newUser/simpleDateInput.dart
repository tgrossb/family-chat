import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:bodt_chat/user.dart';
import 'package:bodt_chat/constants.dart';

class SimpleDateInput extends StatefulWidget {
  final UserParameter<String> initialValue;
  final Function(String, UserParameter<String>) validate;
  final IconData icon;
  final String label;
  final TextInputType keyboardType;
  final bool switchValue;

  // If switchValue is given, the switch will be set to this and disabled
  // To give it an initial value, define the private variable of initialValue
  SimpleDateInput({@required this.initialValue, @required this.validate,
    @required this.icon, @required this.label, @required this.keyboardType, this.switchValue});

  @override
  State<StatefulWidget> createState() => new _SimpleDateInputState();
}

class _SimpleDateInputState extends State<SimpleDateInput> with SingleTickerProviderStateMixin {
  FocusNode node;
  AnimationController backgroundController;
  Animation<double> background;
  UserParameter<String> param;
  DateTextInputFormatter dateFormatter;

  @override
  void initState(){
    super.initState();

    dateFormatter = new DateTextInputFormatter();

    node = FocusNode();
    param = new UserParameter(name: widget.initialValue.name, value: widget.initialValue.value, private: widget.initialValue.private);

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
                  widget.icon,
                  color: iconColor
              ),
            ),
            Flexible(
              child: TextFormField(
                initialValue: widget.initialValue.value,
                focusNode: node,
                keyboardType: widget.keyboardType,
                decoration: InputDecoration(
                    labelText: widget.label,
                    hintText: "mm / dd / yyyy",
                    fillColor: thisCol,
                    suffixIcon: Switch(
                      value: widget.switchValue?? !param.private,
                      onChanged: widget.switchValue == null ? (value) =>
                          setState(() {
                            param.setPrivate(!value);
                          }) : null,
                      activeColor: Theme.of(context).primaryColor,
                    ),
                    border: OutlineInputBorder()
                ),

                onSaved: (value) => param.value = value,
                validator: (value) => widget.validate(value, param),
                inputFormatters: <TextInputFormatter>[
                  WhitelistingTextInputFormatter.digitsOnly,
                  dateFormatter,
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

class DateTextInputFormatter extends TextInputFormatter {
  static List<int> stripNumbers(String s){
    return s.codeUnits.where((charCode) => 47 < charCode && charCode < 58).toList();
  }

  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    List<int> dateNums = stripNumbers(newValue.text);
    int dateCount = dateNums.length;
    List<String> output = [" ", " ", " / ", " ", " ", " / ", " ", " ", " ", " "];
    int outputIndex = 0;
    for (int dateIndex=0; dateIndex<dateCount; dateIndex++){
      outputIndex = dateIndex + (dateIndex > 1 ? (dateIndex > 3 ? 2 : 1) : 0);
      output[outputIndex] = String.fromCharCode(dateNums[dateIndex]);
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