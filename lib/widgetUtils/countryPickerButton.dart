import 'package:flutter/material.dart';
import 'package:bodt_chat/dialogs/countryPickerDialog.dart';
import 'package:bodt_chat/dataUtils/dataBundles.dart';
import 'package:bodt_chat/dataUtils/countryList.dart';

class CountryPickerButton extends StatefulWidget {
  final CountryData initialSelection;
  final Function(CountryData) onSelection;
  final bool showCode = false;
  final double width, height;
  final EdgeInsets padding;

  CountryPickerButton({@required this.onSelection, int selectionIndex: 0, this.width, this.height, this.padding}):
      initialSelection = CountryList.countries[selectionIndex];

  CountryPickerButton.fromName({@required this.onSelection, @required String name, this.width, this.height, this.padding}):
      initialSelection = CountryList.countries.firstWhere((data) => data.name == name);

  CountryPickerButton.fromPhoneCode({@required this.onSelection, @required String phoneCode, this.width, this.height, this.padding}):
      initialSelection = CountryList.countries.firstWhere((data) => data.phoneCode == phoneCode);

  CountryPickerButton.fromIsoCode({@required this.onSelection, @required String isoCode, this.width, this.height, this.padding}):
      initialSelection = CountryList.countries.firstWhere((data) => data.isoCode == isoCode);

  @override
  State<StatefulWidget> createState() => CountryPickerButtonState();
}

class CountryPickerButtonState extends State<CountryPickerButton> {
  CountryData selection;

  @override
  void initState(){
    super.initState();

    selection = widget.initialSelection;
  }

  Widget buildFlag(BuildContext context){
    ThemeData theme = Theme.of(context);
    return Container(
      height: theme.iconTheme.size ?? 24.0, // Set the height to be the same as the prefix icons
      child: widget.showCode ? Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Padding(
            padding: EdgeInsets.only(right: 4.0),
            child: selection.flag,
          ),
          Text(selection.phoneCode, style: theme.inputDecorationTheme.labelStyle),
        ],
      ) : selection.flag,
    );
  }

  Widget buildButtonFace(BuildContext context){
    // If given a specific width and height, add a container on top of the flag
    // to give it those dimensions so taps are responded to all over
    return FittedBox(
      fit: BoxFit.cover,
      child: Container(
        width: widget.width,
        height: widget.height,
        child: Align(
          alignment: Alignment.center,
          child: Padding(
            padding: widget.padding ?? EdgeInsets.all(0.0),
            child: buildFlag(context),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      child: buildButtonFace(context),
      onTap: widget.onSelection == null ? null : startDialog,
    );
  }

  void startDialog() async {
    CountryData result = await showDialog<CountryData>(
        context: context,
        builder: (BuildContext context) => CountryPickerDialog()
    );

    if (result != null)
      updateSelection(result);
  }

  void updateSelection(CountryData data){
    setState(() {
      selection = data;
    });
    widget.onSelection(data);
  }
}