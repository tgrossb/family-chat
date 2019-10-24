/**
 * A button that goes from text to a spinner icon once pressed.
 *
 * Very good for things like log in and sign up actions.  Pretty much anything that
 * has to deal with verification or action that could take a little bit (like network
 * things) to show that everything is still okay.
 *
 * Callbacks: You will likely want to define onClick.  The callback shouldAnimate should
 * only be defined when the button is validating something before animated (like a form
 * submit button that connects to network methods).  The callback structure goes:
 *    shouldAnimate -> *animation may begin* -> onClick(shouldAnimate result)
 * Note that onClick is called no matter what, but it receives the result of shouldAnimate,
 * which defaults to true.
 *
 * A stream can also be given to programmatically 'tap' the button.  To initiate a tap,
 * bring the stream high (set it to 1).
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
  final Function(bool) onClick;
  final Function shouldAnimate;
  final Stream<int> tapInitiator;

  SpinnerButton({Key key, @required this.text, @required this.spinner, @required this.backgroundColor,
    @required this.morphDuration, @required this.fadeTextDuration,
    this.padding, this.endPadding, onClick, shouldAnimate, this.tapInitiator}):
        this.onClick = onClick ?? ((v){}),
        this.shouldAnimate = shouldAnimate ?? (() => true),
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

    if (widget.tapInitiator != null)
      widget.tapInitiator.listen((data){
        if (data == 1 && controller.status != AnimationStatus.forward)
          click();
      });

    super.initState();
  }

  void click() async {
    bool animate = widget.shouldAnimate();
    if (animate)
      controller.forward();
    widget.onClick(animate);
  }

  Widget buildButton(BuildContext context, Widget child){
    Color textColor = widget.text.style.color.withOpacity(fadeText.value);

    return GestureDetector(
      onTap: controller.status == AnimationStatus.forward ? null : click,
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