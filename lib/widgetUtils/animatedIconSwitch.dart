import 'dart:math' as math;
import 'package:flutter/material.dart';

class AnimatedIconSwitch extends StatefulWidget {
  final IconData unselected, selected;
  final Duration duration;
  final Function onPressed;
  final bool initiallySelected;
  final double initialOpacity;
  final Color color;
  final Widget top;

  AnimatedIconSwitch({@required this.unselected, @required this.selected, Duration duration,
    this.onPressed, this.initiallySelected: false, this.initialOpacity: 1.0, this.color, this.top}):
      this.duration = duration ?? Duration(milliseconds: 300);

  @override
  State<StatefulWidget> createState() => AnimatedIconSwitchState();
}

class AnimatedIconSwitchState extends State<AnimatedIconSwitch> with SingleTickerProviderStateMixin {
  AnimationController controller;
  Animation unselectedRotate, unselectedFade, selectedRotate, selectedFade;
  bool isSelected;

  @override
  void initState() {
    super.initState();

    controller = new AnimationController(vsync: this, duration: widget.duration);
    unselectedRotate = new Tween<double>(begin: 0.0, end: math.pi).animate(
        CurvedAnimation(parent: controller, curve: Interval(0.0, 1.0)));
    unselectedFade = new Tween<double>(begin: widget.initialOpacity, end: 0.0).animate(
        CurvedAnimation(parent: controller, curve: Interval(0.0, 0.75)));
    selectedRotate = new Tween<double>(begin: math.pi, end: math.pi*2).animate(
        CurvedAnimation(parent: controller, curve: Interval(0.0, 1.0)));
    selectedFade = new Tween<double>(begin: 0.0, end: widget.initialOpacity).animate(
        CurvedAnimation(parent: controller, curve: Interval(0.25, 1.0)));

    isSelected = widget.initiallySelected;
    if (isSelected)
      controller.value = 1.0;
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      builder: buildButtonAnimation,
      animation: controller,
    );
  }

  void onPressed(){
    if (widget.onPressed == null)
      return;
    setState(() {
      isSelected = !isSelected;
      if (isSelected)
        controller.forward(from: 0.0);
      else
        controller.reverse(from: 1.0);
    });
    widget.onPressed(isSelected);
  }

  Widget buildAnimatedIcon(BuildContext context){
    IconThemeData base = Theme.of(context).iconTheme;
    Color baseColor = widget.color ?? base.color;

    double unselectedOpacity = unselectedFade.value;
    if (widget.onPressed == null)
      unselectedOpacity = isSelected ? 0.0 : base.opacity ?? 1.0;

    double selectedOpacity = selectedFade.value;
    if (widget.onPressed == null)
      selectedOpacity = isSelected ? base.opacity ?? 1.0 : 0.0;

    return Center(
      child: Stack(
        children: <Widget>[
          Transform.rotate(
            angle: unselectedRotate.value,
            child: Opacity(
              opacity: unselectedOpacity,
              child: Icon(
                widget.unselected,
                color: widget.onPressed == null ? Theme.of(context).disabledColor : baseColor,
              ),
            ),
          ),
          Transform.rotate(
            angle: selectedRotate.value,
            child: Opacity(
              opacity: selectedOpacity,
              child: Icon(
                widget.selected,
                color: widget.onPressed == null ? Theme.of(context).disabledColor : baseColor,
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget buildButtonAnimation(BuildContext context, Widget parent){
    return GestureDetector(
        onTap: onPressed,
        child: Container (
          width: 48.0,  // Minimum size to be clickable according to material design guidlines
          height: 48.0,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,

            children: widget.top == null ?
                <Widget>[buildAnimatedIcon(context)] :
                <Widget>[widget.top, buildAnimatedIcon(context)]
          )
        )
    );
  }
}