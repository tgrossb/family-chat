import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:bodt_chat/widgetUtils/appendableListenable.dart';

class ColorPickerButton extends StatefulWidget implements AppendableListenable {
  final Color initialColor;
  final Color borderColor;
  final double borderWidth;
  final double totalRadius;     // Defaults the the minimum clickable size for a button
  final Function(Color) onColorConfirmed;
  final Duration fadeDuration;

  ColorPickerButton({GlobalKey key, @required this.initialColor, @required this.onColorConfirmed,
    this.borderColor = Colors.black, this.borderWidth = 0.0, this.totalRadius = 24.0, Duration fadeDuration}):
      fadeDuration = fadeDuration ?? Duration(milliseconds: 200),
      assert(totalRadius > 0),
      super(key: key ?? GlobalKey());

  @override
  State<StatefulWidget> createState() => ColorPickerButtonState();

  void addListener(Function onConfirmed) async {
    State state = (super.key as GlobalKey).currentState;
    if (state == null)
      return;

    (state as ColorPickerButtonState).addListener(onConfirmed);
  }

  void setCurrentColor(Color color) async {
    State state = (super.key as GlobalKey).currentState;
    if (state == null)
      return;

    (state as ColorPickerButtonState).setCurrentColor(color);
  }

  Color getCurrentColor(){
    State state = (super.key as GlobalKey).currentState;
    if (state == null)
      return null;

    return (state as ColorPickerButtonState).pickedColor;
  }
}

class ColorPickerButtonState extends State<ColorPickerButton> with SingleTickerProviderStateMixin {
  AnimationController colorFader;
  Animation<Color> colorAnimation;

  Color pickedColor;
  Color currentColor;

  List<Function(Color)> onConfirmedListeners;

  @override
  void initState(){
    pickedColor = widget.initialColor;
    currentColor = pickedColor;

    colorFader = AnimationController(vsync: this, duration: widget.fadeDuration)
        ..addListener(() => setState((){}));
    colorAnimation = ColorTween(begin: pickedColor, end: pickedColor).animate(colorFader);
    colorFader.forward();

    onConfirmedListeners = [widget.onColorConfirmed];

    print("Made color picker button state");

    super.initState();
  }

  void addListener(Function(Color) listener) async {
    onConfirmedListeners.add(listener);
  }

  void pickColor() async {
    setState(() {
      colorAnimation = ColorTween(begin: pickedColor, end: currentColor).animate(colorFader);
      pickedColor = currentColor;
      colorFader.forward(from: 0.0);
    });

    for (Function listener in onConfirmedListeners)
      listener(pickedColor);
  }

  void setCurrentColor(Color color){
    setState(() {
      currentColor = color;
      pickedColor = color;
    });
//    pickColor();
  }

  @override
  Widget build(BuildContext context){
    CircleAvatar border = CircleAvatar(
      backgroundColor: widget.borderColor,
      radius: widget.totalRadius,
    );

    CircleAvatar color = CircleAvatar(
      backgroundColor: colorAnimation.value,
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
              pickerColor: pickedColor,
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

  @override
  void dispose() {
    colorFader.dispose();

    print("Disposed color picker button state");

    super.dispose();
  }
}