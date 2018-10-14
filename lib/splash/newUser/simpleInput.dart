import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:bodt_chat/dataUtils/user.dart';
import 'package:bodt_chat/dataUtils/dataBundles.dart';
import 'package:bodt_chat/constants.dart';
import 'package:bodt_chat/widgetUtils/animatedIconSwitch.dart';
import 'package:bodt_chat/widgetUtils/countryPickerButton.dart';

class SimpleInput extends StatefulWidget {
  final UserParameter<String> initialValue;
  final Function(String, UserParameter<String>, bool isRequired, String label) validate;
  final Function(int) requestNextFocus;
  final int location;
  final IconData icon;
  final String label, requiredLabel;
  final TextInputType keyboardType;
  final bool switchValue, isRequired, autovalidate, useCountryPicker;
  final List<TextInputFormatter> inputFormatters;
  final FocusNode focusNode;
  final bool useNew;
  final Widget Function(BuildContext) buildPrefix;
  final Function(CountryData) onSelected;

  // If switchValue is given, the switch will be set to this and disabled
  // To give it an initial value, define the private variable of initialValue
  SimpleInput({@required this.initialValue, @required this.validate,
    @required this.icon, @required this.label, @required this.keyboardType,
    this.switchValue, this.isRequired: false, this.autovalidate: false,
    this.inputFormatters, this.requiredLabel: "* ", @required this.focusNode,
    @required this.requestNextFocus, @required this.location, this.useNew: false,
    this.buildPrefix, this.useCountryPicker: false, this.onSelected
  });

  SimpleInput.fromParams({@required this.initialValue, @required this.validate, @required this.requestNextFocus,
    @required this.location, @required InputFieldParams params}):
        this.icon = params.icon,
        this.label = params.label,
        this.requiredLabel = params.requiredLabel,
        this.keyboardType = params.keyboardType ?? TextInputType.text,
        this.switchValue = params.switchValue,
        this.isRequired = params.isRequired ?? false,
        this.autovalidate = params.autovalidate ?? false,
        this.inputFormatters = params.formatters,
        this.useNew = params.useNew ?? false,
        this.buildPrefix = params.buildPrefix,
        this.useCountryPicker = params.useCountryPicker ?? false,
        this.onSelected = params.onSelected,
        this.focusNode = params.focusNode;

  @override
  State<StatefulWidget> createState() => new SimpleInputState();
}

class SimpleInputState extends State<SimpleInput> with SingleTickerProviderStateMixin {
  static IconData globeIcon = IconData(0xf57d, fontFamily: 'solid');
  AnimationController backgroundController;
  Animation<double> background;
  UserParameter<String> param;
  // Not going to lie... I forgot what this variable is for
  String prefix = "";
  GlobalKey<FormFieldState> fieldKey;
  bool valid = true;

  @override
  void initState(){
    super.initState();

    fieldKey = new GlobalKey();
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

  String validate(String value){
    param.value = prefix + value;
    String validation = widget.validate(prefix + value, param, widget.isRequired, widget.label);
//    setState(() {
      valid = validation == null;
//    });
    return validation;
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      builder: buildFormAnimation,
      animation: backgroundController,
    );
  }

  Color getCurrentBorderColor(BuildContext context){
    Color defaultIconColor = Colors.black45;  // Found in Flutter source code (https://github.com/flutter/flutter/blob/master/packages/flutter/lib/src/material/input_decorator.dart, line 1630 ish)
    Color focusedIconColor = Theme.of(context).primaryColor;
    if (valid)
      return widget.focusNode.hasFocus ? focusedIconColor : defaultIconColor;
    else
      return widget.focusNode.hasFocus ? Theme.of(context).inputDecorationTheme.errorStyle.color : Theme.of(context).inputDecorationTheme.errorStyle.color;
  }

  Widget buildSwitch(BuildContext context){
    return AnimatedIconSwitch(
      initiallySelected: !param.private,
      unselected: Icons.lock,
      selected: globeIcon,
      duration: Duration(milliseconds: 300),
      onPressed: widget.switchValue == null ? () =>
          setState((){
            param.setPrivate(!param.private);
          }) : null,
      color: getCurrentBorderColor(context),
    );
  }

  Widget rightBorderAndPad(BuildContext context, Widget child, EdgeInsets contentPadding){
    return Container(
      margin: EdgeInsets.only(right: contentPadding.left),
      decoration: BoxDecoration(
        border: Border(
          right: BorderSide(color: getCurrentBorderColor(context))
        )
      ),
      child: child,
    );
  }

  Widget buildFormAnimation(BuildContext context, Widget child){
    ThemeData theme = Theme.of(context);
    Color goalColor = theme.inputDecorationTheme.fillColor;
    Color thisCol = goalColor.withOpacity(goalColor.opacity * background.value);

    Color iconBaseColor = theme.inputDecorationTheme.labelStyle.color;
    Color iconColor = iconBaseColor.withOpacity(iconBaseColor.opacity - 2*goalColor.opacity * background.value);

    EdgeInsets contentPadding = theme.inputDecorationTheme.contentPadding;

    Widget prefixIcon;
    if (widget.useCountryPicker)
      prefixIcon = CountryPickerButton(
        onSelection: widget.onSelected ?? (CountryData data) => prefix = data.phoneCode,
        height: 58.0,
        padding: EdgeInsets.symmetric(horizontal: contentPadding.left)
      );
    else if (widget.buildPrefix != null)
      prefixIcon = widget.buildPrefix(context);

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
                key: fieldKey,
                initialValue: widget.initialValue.value,
                focusNode: widget.focusNode,
                keyboardType: widget.keyboardType,
                autovalidate: widget.autovalidate,
                decoration: InputDecoration(
                    labelText: (widget.isRequired ? widget.requiredLabel : "") + widget.label,
                    fillColor: thisCol,
                    suffixIcon: buildSwitch(context),
                    prefixIcon: prefixIcon == null ? null : rightBorderAndPad(context, prefixIcon, contentPadding),
                    contentPadding: prefixIcon == null ? contentPadding : contentPadding.copyWith(left: 0.0),
                    border: OutlineInputBorder()
                ),

                onSaved: (value) => param.value = value,
                validator: validate,
                inputFormatters: widget.inputFormatters,
                onFieldSubmitted: (String s){
                  fieldKey.currentState.validate();
                  widget.requestNextFocus(widget.location);
                },
              ),
            ),
          ],
        )
    );
  }
}