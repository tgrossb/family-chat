import 'package:flutter/material.dart';
import 'package:bodt_chat/widgetUtils/colorPickerButton.dart';
import 'package:bodt_chat/widgetUtils/resettableTile.dart';
import 'package:bodt_chat/dataUtils/dataBundles.dart';

class ColorsConfig extends StatefulWidget {
  final GroupThemeData themeData;

  ColorsConfig({GlobalKey key, @required this.themeData}):
      super(key: key ?? GlobalKey());

  @override
  State<StatefulWidget> createState() => ColorsConfigState(themeData: themeData);

  ColorsConfigState getState(){
    State state = (super.key as GlobalKey).currentState;
    if (state == null)
      return null;
    return state as ColorsConfigState;
  }
}

class ColorsConfigState extends State<ColorsConfig> {
  Color accentColor, backgroundColor;
  GroupThemeData themeData;

  ColorsConfigState({@required this.themeData});

  @override
  void initState() {
    accentColor = themeData.accentColor;
    backgroundColor = themeData.backgroundColor;

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
        child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ResettableTile(
                leading: Icon(Icons.color_lens),
                title: Text("Accent Color"),
                trailing: ColorPickerButton(
                  initialColor: accentColor,
                  onColorConfirmed: (c) => setState(() => accentColor = c),
                ),
                onReset: (picker) => setState(() => accentColor = themeData.accentColor),
//                canReset: (pickerValue) => pickerValue != themeData.accentColor,
                canReset: accentColor != themeData.accentColor,
              ),
/*
              Divider(),

              ResettableTile(
                leading: Icon(Icons.color_lens),
                title: Text("BackgroundColor"),
                trailing: ColorPickerButton(
                  initialColor: backgroundColor,
                  borderWidth: 2.5,
                  borderColor: Utils.pickTextColor(backgroundColor),
                  onColorConfirmed: (c) => setState(() => backgroundColor = c)
                ),
                onReset: (picker) => picker.setCurrentColor(backgroundColor),
                canReset: (picker) => picker.getCurrentColor() != data.groupThemeData.backgroundColor,
              )
*/
            ]
        )
    );
  }
}