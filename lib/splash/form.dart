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

class FutureFormEntry {
  FormEntryType type;
  int id;

  FutureFormEntry({@required this.type, this.id = -1});
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
      this.validator = validator ?? null,
      super(type: FormEntryType.INPUT);
}

class FormSubmitButton extends FormEntry {
  String buttonText;

  FormSubmitButton({@required this.buttonText}):
      super(type: FormEntryType.SUBMIT);
}

class FormDecor extends FormEntry {
  Widget widget;

  FormDecor({@required this.widget}):
      super(type: FormEntryType.DECOR);
}

abstract class AutoAdvanceForm extends StatefulWidget {
  final FormType formType;
  final List<FutureFormEntry> futureFormEntries;
  final int _inputCount, _submitCount;

  AutoAdvanceForm({Key key, @required this.formType, @required this.futureFormEntries}):
        _inputCount = (futureFormEntries.where((el) => el.type == FormEntryType.INPUT)).length,
        _submitCount = (futureFormEntries.where((el) => el.type == FormEntryType.SUBMIT)).length,
        super(key: key){
    assert(_submitCount == 1);

    // If the FutureFormEntries don't have defined ids, give them positional ids
    if (futureFormEntries.where((el) => el.id < 0).length > 0)
      for (int c=0; c<futureFormEntries.length; c++)
        futureFormEntries[c].id = c;
  }

  @override
  State<AutoAdvanceForm> createState() => AutoAdvanceFormState();

  static RegExp emailRegex = RegExp(r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$');
  static String emailValidator(String value){
    if (value.isEmpty)
      return "Please enter your email";
    if (!emailRegex.hasMatch(value))
      return "Hmm that doesn't look like an email";
    return null;
  }

  FormEntry buildEntry(BuildContext context, int id);
  Future<bool> actuate(List<String> values);
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

    values = List(widget._inputCount);
    advancementNodes = List(widget._inputCount-1);

    for (int c=0; c<widget._inputCount; c++){
      values[c] = "";

      if (c > 0)
        advancementNodes[c-1] = FocusNode();
    }
  }

  Widget buildInput(FormInput inputParams, int inputPos){
    bool last = inputPos == widget._inputCount-1;
    return TextFormField(
      enabled: !_actuating,
      focusNode: inputPos > 0 ? advancementNodes[inputPos-1] : null,
      controller: last ? finalController : null,
      style: TextStyle(color: Consts.TEXT_GRAY),
      decoration: InputDecoration(labelText: inputParams.name),
      textInputAction: last ? TextInputAction.done : TextInputAction.next,
      keyboardType: inputParams.keyboardType,
      validator: inputParams.validator,
      onSaved: (value){
        values[inputPos] = value;
      },
      onFieldSubmitted: last ? (value){
        tapInitiator.add(1);
      } : (value){
        FocusScope.of(context).requestFocus(advancementNodes[inputPos]);
      },
      obscureText: inputParams.obscure,
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
    List<Widget> formChildren = List(widget.futureFormEntries.length);
    int inputCounter = 0;
    for (int c=0; c<widget.futureFormEntries.length; c++){
      FormEntry entry = widget.buildEntry(context, widget.futureFormEntries[c].id);
      assert(entry.type == widget.futureFormEntries[c].type);

      if (entry.type == FormEntryType.INPUT) {
        formChildren[c] = buildInput(entry, inputCounter);
        inputCounter++;
      } else if (entry.type == FormEntryType.SUBMIT)
        formChildren[c] = buildSubmitButton(entry);
      else
        formChildren[c] = (entry as FormDecor).widget;
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

      bool success = await widget.actuate(values);

      if (!success) {
        setState(() {
          _actuating = false;
        });

//        FocusScope.of(context).requestFocus(advancementNodes[advancementNodes.length-1]);
        FocusScope.of(_formKey.currentContext).requestFocus(advancementNodes[0]);
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