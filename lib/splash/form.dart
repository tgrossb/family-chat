/**
 * The AutoAdvanceForm class provides a way to generically define forms of very
 * similar styles.  It is minimally customizable because it is intended to streamline
 * the look and feel of forms.  In the future, if more customizability is needed, a more
 * general version will be created.
 *
 * The AutoAdvanceForm receives a list of elements that it will then layout.
 * An element could be one of the following types:
 *   [*] Input - An input field, which has:
 *        [-] A name - the text displayed in and above the input field
 *        [-] A keyboard type - the format of the keyboard for this field (defaults to text)
 *        [-] A validator - directly the same as the validator in a TextInputField
 *        [-] An obscure flag - indicates if the field should be obscured (defaults to false)
 *   [*] Submit - The spinner button for the form, which has:
 *        [-] Button text - the text to be displayed on the spinner button in its natural state
 *   [*] Decor - A child of the form layout that is not directly related to the form content.
 *               This could mean something like an additional button or spacers.  This has:
 *        [-] An id - the id given to the buildDecor method when the widget is built
 *
 * The AutoAdvanceForm also must receive an actuator function.  The actuator function is called
 * if the form validates, and is awaited upon by the spinner button.  In other words, this
 * function should perform all of the external validation of the data in the form (login, etc).
 *
 * Finally, if any decors are defined, the AutoAdvanceForm must receive a buildDecor callback,
 * which will be called with a context and id for each decor specified.
 *
 * Written by: Theo Grossberndt
 */

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hermes/consts.dart';
import 'package:hermes/widgets/spinnerButton.dart';
import 'package:hermes/widgets/checkProgressIndicator.dart';
import 'dart:async';

enum FormType {
  LOGIN_FORM, SIGNUP_FORM, OTHER
}

enum FormEntryType {
  INPUT, DECOR, SUBMIT
}

abstract class FormEntry {
  FormEntryType type;
  FormEntry({@required this.type});
}

class FormInput extends FormEntry {
  String name;
  TextInputType keyboardType;
  String Function(String) validator;
  bool obscure;

  FormInput({@required this.name,
    this.keyboardType = TextInputType.text,
    Function validator, this.obscure = false}):
      this.validator = validator ?? ((value) => null),
      super(type: FormEntryType.INPUT);
}

class FormSubmitButton extends FormEntry {
  String buttonText;

  FormSubmitButton({@required this.buttonText}):
      super(type: FormEntryType.SUBMIT);
}

class FormDecor extends FormEntry {
  int id;

  FormDecor({@required this.id}):
      super(type: FormEntryType.DECOR);
}

class AutoAdvanceForm extends StatefulWidget {
  final FormType formType;
  final List<FormEntry> entries;
  final Function actuator;
  final Function _buildDecor;
  final int inputCount;
  AutoAdvanceForm({Key key, @required this.formType,
    @required this.entries, @required this.actuator, Function buildDecor, @required this.inputCount}):
//      inputCount = entries.where((element) => element.type == FormEntryType.INPUT).length,
      this._buildDecor = buildDecor ?? ((context, id) => null),
      super(key: key);

  @override
  State<AutoAdvanceForm> createState() => AutoAdvanceFormState();

  static RegExp emailRegex = RegExp(r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$');
  static emailValidator(String value){
    if (value.isEmpty)
      return "Please enter your email";
    if (!emailRegex.hasMatch(value))
      return "Hmm that doesn't look like an email";
    return null;
  }
}

class AutoAdvanceFormState extends State<AutoAdvanceForm> {
  final _formKey = GlobalKey<FormState>();
  final StreamController<int> tapInitiator = StreamController();
  final StreamController<int> progressFinisher = StreamController();

  List<String> values;
  List<FocusNode> advancementNodes;
  TextEditingController finalController = TextEditingController();

  bool _autovalidate = false;

  bool _actuating = false;

  @override
  void initState(){
    super.initState();

    values = List(widget.inputCount);
    advancementNodes = List(values.length-1);
    for (int c=0; c<values.length; c++) {
      values[c] = "";
      if (c != values.length-1)
        advancementNodes[c] = FocusNode();
    }
  }

  Widget buildInput(FormInput inputParams, int c){
    bool last = c == widget.inputCount - 1;
    return TextFormField(
      enabled: !_actuating,
      focusNode: c > 0 ? advancementNodes[c] : null,
      controller: last ? finalController : null,
      style: TextStyle(color: Consts.TEXT_GRAY),
      decoration: InputDecoration(labelText: inputParams.name),
      textInputAction: last ? TextInputAction.done : TextInputAction.next,
      keyboardType: inputParams.keyboardType,
      validator: inputParams.validator,
      onSaved: (value){
        values[c] = value;
      },
      onFieldSubmitted: c < widget.entries.length-1 ? (value){
        FocusScope.of(context).requestFocus(advancementNodes[c]);
      } : (value){
        tapInitiator.add(1);
      },
    );
  }

  Widget buildSubmitButton(FormSubmitButton buttomParams){
    return SpinnerButton(
      text: Text(
        buttomParams.buttonText,
        style: TextStyle(fontSize: 24, fontFamily: 'Rubik', color: Colors.white)
      ),
      spinner: CheckProgressIndicator(
        color: Consts.BLUE,
        strokeWidth: 2,
        finish: progressFinisher.stream,
      ),
      backgroundColor: Consts.GREEN,
      morphDuration: Duration(seconds: 1),
      fadeTextDuration: Duration(milliseconds: 250),
      shouldAnimate: shouldAnimate,
      onClick: actuate,
      padding: EdgeInsets.symmetric(horizontal: 64, vertical: 16),
      endPadding: EdgeInsets.symmetric(horizontal: 16),
      tapInitiator: tapInitiator.stream,
    );
  }

  @override
  Widget build(BuildContext context){
    List<Widget> formChildren = List(widget.entries.length);
    for (int c=0; c<formChildren.length; c++){
      if (widget.entries[c].type == FormEntryType.INPUT)
        formChildren.add(buildInput(widget.entries[c], c));
      else if (widget.entries[c].type == FormEntryType.SUBMIT)
        formChildren.add(buildSubmitButton(widget.entries[c]));
      else
        formChildren.add(widget._buildDecor(context, (widget.entries[c] as FormDecor).id));
    }

    return Form(
      key: _formKey,
      autovalidate: _autovalidate,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: formChildren,
      ),
    );
  }

  // Validates the form
  bool shouldAnimate(){
    setState(() {
      _autovalidate = true;
    });

    if (_formKey.currentState.validate()){
      _formKey.currentState.save();
      return true;
    }

    return false;
  }

  // The entry point for logging in from the button
  Future<bool> actuate(bool valid) async {
    if (valid) {
      setState((){
        _actuating = true;
      });

      bool success = await widget.actuator(values);

      if (!success) {
        setState(() {
          _actuating = false;
        });

        FocusScope.of(context).requestFocus(advancementNodes[advancementNodes.length-1]);
        finalController.clear();
      } else
        progressFinisher.add(1);

      return success;
    }
    return false;
  }

  @override
  void dispose() {
    tapInitiator.close();
    progressFinisher.close();
    super.dispose();
  }
}