import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

class ColorPickerButton extends StatefulWidget {
  final Color initialColor;
  final Color borderColor;
  final double borderWidth;
  final double totalRadius;     // Defaults the the minimum clickable size for a button
  final Function(Color) onColorConfirmed;

  ColorPickerButton({@required this.initialColor, @required this.onColorConfirmed,
    this.borderColor = Colors.black, this.borderWidth = 0.0, this.totalRadius = 24.0}):
      assert(totalRadius > 0);

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
    CircleAvatar border = CircleAvatar(
      backgroundColor: widget.borderColor,
      radius: widget.totalRadius,
    );

    CircleAvatar color = CircleAvatar(
      backgroundColor: pickedColor,
      radius: widget.totalRadius - widget.borderWidth,
    );

    return GestureDetector(
      onTap: showColorPicker,
      child: Container(
        width: widget.totalRadius*2,
        height: widget.totalRadius*2,
        child: Stack(
          children: widget.borderWidth <= 0 ? <Widget>[color] : <Widget>[border, color],
          alignment: Alignment.center,
        ),
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
              child: new Text("Cancel"),
              onPressed: () => Navigator.pop(context),
              textColor: Colors.redAccent,
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