import 'package:flutter/material.dart';

class ResettableTile extends StatefulWidget {
  final Widget leading, title, trailing;
  final Function onReset, onTap, onLongPress;
  final Duration duration;
  final bool initiallyResettable, canReset;
  
  ResettableTile({GlobalKey key, this.leading, @required this.trailing, this.title,
    @required this.onReset, @required this.canReset, Duration duration,
    this.onTap, this.onLongPress, this.initiallyResettable}):
      duration = duration ?? Duration(milliseconds: 1000),
      super(key: key ?? GlobalKey());

  @override
  State<StatefulWidget> createState() => ResettableTileState();
}

class ResettableTileState extends State<ResettableTile> with SingleTickerProviderStateMixin {
  AnimationController growFadeAnimationController;
  Animation<double> growFadeAnimation;
  bool resetShowing;

  @override
  void initState() {
    growFadeAnimationController = AnimationController(vsync: this, duration: widget.duration);
    growFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: growFadeAnimationController, curve: Curves.ease));

    growFadeAnimationController.addStatusListener((status){
      if (status == AnimationStatus.dismissed)
        widget.onReset(widget.trailing);
    });


    if (widget.canReset)
      growFadeAnimationController.forward();

    super.initState();
  }

  @override
  Widget build(BuildContext context){
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        ListTile(
          leading: widget.leading,
          trailing: widget.trailing,
          title: widget.title,
          onTap: widget.onTap,
          onLongPress: widget.onLongPress,
        ),

        SizeTransition(
          sizeFactor: growFadeAnimation,
            child: FadeTransition(
              opacity: growFadeAnimation,
              child: ButtonTheme.bar(
                child: FlatButton(
                  onPressed: (){
                    growFadeAnimationController.reverse();
                  },
                  child: Text("Reset"),
                  textColor: Colors.red,
                ),
              ),
            )
          ),
      ],
    );
  }

  @override
  void dispose() {
    growFadeAnimationController.dispose();
    print("Disposed");
    super.dispose();
  }
}