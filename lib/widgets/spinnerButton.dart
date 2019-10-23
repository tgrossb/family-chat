/**
 * A button that goes from text to a spinner icon once pressed.
 *
 * Very good for things like log in and sign up actions.  Pretty much anything that
 * has to deal with verification or action that could take a little bit (like network
 * things) to show that everything is still okay.
 *
 * Written by: Theo Grossberndt
 */

import 'package:flutter/material.dart';

class SpinnerButton extends StatefulWidget {
  final Text text;
  final Widget spinner;
  final Color backgroundColor;
  final Duration morphDuration, fadeTextDuration;
  final EdgeInsets padding, endPadding;
  final Function onClick;

  SpinnerButton({Key key, @required this.text, @required this.spinner, @required this.backgroundColor,
    @required this.morphDuration, @required this.fadeTextDuration,
    this.padding, this.onClick, this.endPadding}):
        super(key: key);

  @override
  State<SpinnerButton> createState() => SpinnerButtonState();
}

class SpinnerButtonState extends State<SpinnerButton> with SingleTickerProviderStateMixin {
  double textHeight, textWidth, totalHeight, totalWidth;
  AnimationController controller;
  Animation fadeText, widthMorph;
  EdgeInsets padding;

  @override
  void initState(){
    // Set up the animations that this has to take care of (fade text out and morph to a circle)
    controller = AnimationController(vsync: this, duration: widget.morphDuration);

    double fadeIntervalLength = widget.fadeTextDuration.inMilliseconds / widget.morphDuration.inMilliseconds;
    fadeText = Tween<double>(begin: 1.0, end: 0.0).animate(
        CurvedAnimation(parent: controller.view, curve: Interval(0.0, fadeIntervalLength)));

    TextSpan span = TextSpan(text: widget.text.data, style: widget.text.style);
    TextPainter buttonText = TextPainter(text: span, textDirection: TextDirection.ltr);
    buttonText.layout();
    textHeight = buttonText.height;
    textWidth = buttonText.width;

    padding = widget.padding ?? EdgeInsets.symmetric(vertical: 8, horizontal: 16);
    EdgeInsets endPadding = widget.endPadding ?? padding;
    totalHeight = textHeight + padding.top + padding.bottom;
    totalWidth = textWidth + padding.left + padding.right;

    // Morph down to a square through the width
    widthMorph = Tween(begin: totalWidth, end: totalHeight+endPadding.left+endPadding.right).animate(
        CurvedAnimation(parent: controller.view, curve: Curves.easeOutQuint));

    super.initState();
  }

  void startAnimation() async {
    widget.onClick();
    controller.forward();
  }

  Widget buildButton(BuildContext context, Widget child){
    Color textColor = widget.text.style.color.withOpacity(fadeText.value);

    return GestureDetector(
      onTap: controller.status == AnimationStatus.forward ? null : startAnimation,
      child: Stack(
        children: <Widget>[
          Center(
            child: Container(
              width: widthMorph.value,
              height: totalHeight,
              decoration: new BoxDecoration(
                  color: widget.backgroundColor,
                  borderRadius: BorderRadius.circular(totalHeight/2)
              ),
            ),
          ),

          Padding(
            padding: padding,
            child: Center(
              child: fadeText.value > 0.1 ? Text(
                widget.text.data,
                style: widget.text.style.copyWith(color: textColor),
                textAlign: TextAlign.center,
              ) : SizedBox(
                width: textHeight,
                height: textHeight,
                child: widget.spinner,
              ),
            ),
          ),

        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: buildButton,
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}