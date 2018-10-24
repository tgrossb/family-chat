import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

class ColorPickerButton extends StatefulWidget {
  final Color initialColor;
  final Function(Color) onColorConfirmed;

  ColorPickerButton({@required this.initialColor, @required this.onColorConfirmed});

  @override
  State<StatefulWidget> createState() => ColorPickerButtonState();
}

class ColorPickerButtonState extends State<ColorPickerButton> {
  Color pickedColor;
  Color currentColor;

  @override
  void initState(){
    pickedColor = widget.initialColor;
    currentColor = pickedColor;
    super.initState();
  }

  void pickColor() async {
    setState(() {
      pickedColor = currentColor;
    });
    widget.onColorConfirmed(pickedColor);
  }

  @override
  Widget build(BuildContext context){
    return GestureDetector(
      onTap: showColorPicker,
      child: CircleAvatar(
        backgroundColor: pickedColor,
      ),
    );
  }

  void showColorPicker(){
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
          contentPadding: EdgeInsets.only(),
          content: SingleChildScrollView(
            padding: EdgeInsets.all(0.0),
            child: ColorPicker(
              pickerColor: widget.initialColor,
              onColorChanged: (color) => setState(() => currentColor = color),
            ),
          ),

          actions: <Widget>[
            FlatButton(
              child: new Text("Cancel", style: Theme.of(context).primaryTextTheme.button.copyWith(color: Colors.redAccent),),
              onPressed: () => Navigator.pop(context),
            ),

            FlatButton(
              child: Text("Pick color"),
              onPressed: (){
                pickColor();
                Navigator.of(context).pop();
              },
            )
          ],
        )
    );
  }
}