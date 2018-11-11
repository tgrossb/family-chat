import 'package:flutter/material.dart';
import 'package:bodt_chat/widgetUtils/colorPickerButton.dart';
import 'package:bodt_chat/widgetUtils/resettableTile.dart';
import 'package:bodt_chat/dataUtils/dataBundles.dart';
import 'package:bodt_chat/singleGroup/settings/testResettable.dart';

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
  bool resettable;

  ColorsConfigState({@required this.themeData});

  @override
  void initState() {
    accentColor = themeData.accentColor;
    backgroundColor = themeData.backgroundColor;

    resettable = false;

    super.initState();
  }

  @override
  Widget build(BuildContext context){
    /*
    Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          ListTile(
            leading: Icon(Icons.color_lens),
            title: Text("Accent Color"),
            trailing: IconButton(icon: Icon(Icons.swap_horiz), onPressed: () => setState(() {
              selected = !selected;
            })),
          ),

          ButtonTheme.bar(
            child: FlatButton(onPressed: () => print("Press"), child: Text('Press here'), textColor: selected ? Colors.red : Colors.black),
          )
        ],
      )
    */
    return Card(
      child: TestResettable(
        leading: Icon(Icons.color_lens),
        title: Text("Accent Color"),
        trailing: IconButton(
          onPressed: () => setState(() => resettable = !resettable),
          icon: Icon(Icons.swap_horiz),
        ),
        canReset: () => resettable,
        onReset: () => setState(() => resettable = false),
      ),
    );
  }

//  @override
  Widget build2(BuildContext context) {
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