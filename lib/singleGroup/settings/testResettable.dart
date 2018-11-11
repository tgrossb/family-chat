import 'package:flutter/material.dart';

class TestResettable extends StatefulWidget {
  final Widget leading, title;
  final Widget trailing;
  final Function canReset;
  final Function onReset;
  final Duration duration;

  TestResettable({@required this.leading, @required this.title, @required this.trailing, @required this.canReset, @required this.onReset,
                    Duration duration}):
    duration = duration ?? Duration(milliseconds: 500);

  @override
  State<StatefulWidget> createState() => TestResettableState();
}

class TestResettableState extends State<TestResettable> with SingleTickerProviderStateMixin {
  AnimationController growFadeController;
  Animation<double> growFadeAnimation;
  bool resetShowing;

  @override
  void initState() {
    growFadeController = AnimationController(vsync: this, duration: widget.duration);
    growFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: growFadeController, curve: Curves.elasticOut));

    growFadeController.addStatusListener((status){
      print("Recieved status: $status");
    });

    resetShowing = false;

    super.initState();
  }

  void handlePress() async {
    bool canReset = widget.canReset();
    if (canReset && !resetShowing)
      growFadeController.forward();
    else if (!canReset && resetShowing)
      growFadeController.reverse();

    setState(() {
      resetShowing = canReset;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        ListTile(
          leading: widget.leading,
          title: widget.title,
          trailing: NotificationListener(
            onNotification: (t){
              print("Intercepted touch");
              handlePress();
              return false;
            },
            child: widget.trailing,
          ),
        ),

        SizeTransition(
          axis: Axis.vertical,
          sizeFactor: growFadeAnimation,
          child: FadeTransition(
            opacity: growFadeAnimation,
            child: ButtonTheme.bar(
              child: Align(
                alignment: Alignment.centerRight,
                child: FlatButton(
                  onPressed: widget.onReset,
                  child: Text("Reset"),
                  textColor: Colors.red,
                ),
              ),
            ),
          ),
        )
      ],
    );
  }

  @override
  void dispose() {
    growFadeController.dispose();
    print("Disposed");
    super.dispose();
  }
}