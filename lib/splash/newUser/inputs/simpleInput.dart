import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:bodt_chat/dataUtils/user.dart';
import 'package:bodt_chat/constants.dart';

class SimpleInput extends StatefulWidget {
  final UserParameter<String> initialValue;
  final Function(String, UserParameter<String>, bool isRequired, String label) validate;
  final Function(int) requestNextFocus;
  final int focusIndex;
  final IconData icon;
  final String label, requiredLabel;
  final TextInputType keyboardType;
  final bool switchValue, isRequired, autovalidate;
  final List<TextInputFormatter> inputFormatters;
  final FocusNode focusNode;

  // If switchValue is given, the switch will be set to this and disabled
  // To give it an initial value, define the private variable of initialValue
  SimpleInput({@required this.initialValue, @required this.validate,
    @required this.icon, @required this.label, @required this.keyboardType,
    this.switchValue, this.isRequired: false, this.autovalidate: false,
    this.inputFormatters, this.requiredLabel: "* ", @required this.focusNode,
    @required this.requestNextFocus, @required this.focusIndex
  });

  @override
  State<StatefulWidget> createState() => new SimpleInputState();
}

class SimpleInputState extends State<SimpleInput> with SingleTickerProviderStateMixin {
  AnimationController backgroundController;
  Animation<double> background;
  UserParameter<String> param;

  @override
  void initState(){
    super.initState();

    param = new UserParameter(name: widget.initialValue.name, value: widget.initialValue.value, private: widget.initialValue.private);

    Tween<double> opacityTween = Tween(begin: 0.0, end: 1.0);
    backgroundController = AnimationController(vsync: this, duration: Duration(milliseconds: kSELECT_FIELD_SHADE));
    background = opacityTween.animate(backgroundController);

    widget.focusNode.addListener((){
      setState(() {
        if (widget.focusNode.hasFocus)
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
                focusNode: widget.focusNode,
                keyboardType: widget.keyboardType,
                autovalidate: widget.autovalidate,
                decoration: InputDecoration(
                  labelText: (widget.isRequired ? widget.requiredLabel : "") + widget.label,
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
                validator: (value){
                  param.value = value;
                  return widget.validate(value, param, widget.isRequired, widget.label);
                },
                inputFormatters: widget.inputFormatters,
                onFieldSubmitted: widget.requestNextFocus(widget.focusIndex),
              ),
            ),
          ],
        )
    );
  }
}