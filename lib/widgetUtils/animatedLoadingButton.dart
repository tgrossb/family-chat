import 'package:flutter/material.dart';

class AnimatedLoadingButton extends StatefulWidget {
  final Container container;
  final Duration duration;
  final Curve curve;
//  final
  AnimatedLoadingButton({GlobalKey key, @required this.container, @required this.duration, this.curve}):
      super(key: key ?? GlobalKey());

  @override
  State createState() => AnimatedLoadingButtonState();

  void startAnimation() async {
    (super.key as GlobalKey).currentState.startAnimation();
  }

  void finishAnimation() async {
    (super.key as GlobalKey).currentState.finishAnimation();
  }
}

class AnimatedLoadingButtonState extends State<AnimatedLoadingButton> {
  void startAnimation() async {

  }

  @override
  Widget build(BuildContext context) {
    Container container = widget.container;

    return GestureDetector(
      child: AnimatedContainer(
        duration: widget.duration,
        curve: widget.curve,

        alignment: container.alignment,
        padding: container.padding,
        decoration: container.decoration,
        foregroundDecoration: container.foregroundDecoration,
        constraints: container.constraints,
        margin: container.margin,
        transform: container.transform,

        child: container.child,
      ),
    );
  }
}