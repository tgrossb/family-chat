import 'package:flutter/material.dart';

class ResettableTile extends StatefulWidget {
  Widget leading, trailing, title;
  Function onReset, onTap, onLongPress;
  Duration duration;
  
  ResettableTile({GlobalKey key, this.leading, this.trailing, this.title, this.onReset, Duration duration, this.onTap, this.onLongPress}):
      duration = duration ?? Duration(milliseconds: 200),
      super(key: key ?? GlobalKey());

  @override
  State<StatefulWidget> createState() => ResettableTileState();

  void valueChanged(bool canReset) async {
    State currentState = (super.key as GlobalKey).currentState;
    if (currentState == null)
      return;

    (currentState as State<ResettableTile>).widget.valueChanged(canReset);
  }
}

class ResettableTileState extends State<ResettableTile> with SingleTickerProviderStateMixin {
  AnimationController growFadeAnimationController;
  Animation<double> growFadeAnimation;
  bool resetShowing;

  @override
  void initState() {
    growFadeAnimationController = AnimationController(vsync: this, duration: widget.duration);
    growFadeAnimation = CurvedAnimation(parent: growFadeAnimation, curve: Curves.elasticOut);

    resetShowing = false;

    super.initState();
  }

  void valueChanged(bool canReset) async {
    if (canReset && !resetShowing)
      growFadeAnimationController.forward();
    else if (!canReset && resetShowing)
      growFadeAnimationController.reverse();

    setState((){
      resetShowing = canReset;
    });
  }

  @override
  Widget build(BuildContext context){
    return ListTile(
        leading: widget.leading,
        trailing: widget.trailing,
        title: widget.title,
        onTap: widget.onTap,
        onLongPress: widget.onLongPress,

        subtitle: SizeTransition(
          sizeFactor: growFadeAnimation,
          child: Opacity(
            opacity: growFadeAnimation.value,
            child: ButtonTheme.bar(
              child: FlatButton(
                onPressed: widget.onReset,
                child: Text("Reset"),
                textColor: Colors.red,
              ),
            ),
          )
        ),
    );
  }

  @override
  void dispose() {
    growFadeAnimationController.dispose();
    super.dispose();
  }
}