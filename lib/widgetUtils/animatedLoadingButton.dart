import 'dart:async';
import 'package:flutter/material.dart';
import 'package:bodt_chat/constants.dart';
import 'package:bodt_chat/loaders/loader.dart';

class AnimatedLoadingButton extends StatefulWidget {
  final Text text;
  final Loader loaderAnimation;
  final Color backgroundColor;
  final Duration _morphDuration;
  final double fadeTextPortion;
  final EdgeInsets padding;

  AnimatedLoadingButton({GlobalKey key, @required this.text, @required this.loaderAnimation, @required this.backgroundColor,
    Duration morphDuration,
    this.fadeTextPortion = LoadingButtonConstants.kBUTTON_FADE_TEXT_PORTION,
    this.padding = LoadingButtonConstants.kBUTTON_PADDING}):
      _morphDuration = morphDuration ?? Duration(milliseconds: LoadingButtonConstants.kBUTTON_MORPH_DURATION),
      super(key: key ?? GlobalKey());

  @override
  State createState() => AnimatedLoadingButtonState();

  Future<int> finishAnimation() async {
    return await ((super.key as GlobalKey).currentState as AnimatedLoadingButtonState).finishAnimation();
  }
}

class AnimatedLoadingButtonState extends State<AnimatedLoadingButton> with SingleTickerProviderStateMixin {
  double textHeight, textWidth, totalHeight, totalWidth;
  AnimationController controller;
  Animation fadeText, widthMorph, heightMorph, colorMorph, radiusMorph;

  @override
  void initState(){
    // Set up the animations that this has to take care of (morph and fade text)
    controller = AnimationController(vsync: this, duration: widget._morphDuration);
    fadeText = Tween<Opacity>(begin: Opacity(opacity: 1.0), end: Opacity(opacity: 0.0)).animate(
      CurvedAnimation(parent: controller.view, curve: Interval(0.0, widget.fadeTextPortion)));

    // These need the loader's container and the button's initial container
    TextPainter buttonText = TextPainter(text: widget.text.textSpan, textDirection: TextDirection.ltr);
    buttonText.layout();
    textHeight = buttonText.height;
    textWidth = buttonText.width;
    
    totalHeight = textHeight + widget.padding.top + widget.padding.bottom;
    totalWidth = textWidth + widget.padding.left + widget.padding.right;

    Container loaderContainer = widget.loaderAnimation.getSingleBaseContainer();

    double widthEnd = loaderContainer.constraints.maxWidth;
    widthMorph = Tween(begin: totalWidth, end: widthEnd).animate(
        CurvedAnimation(parent: controller, curve: Curves.linear));

    double heightEnd = loaderContainer.constraints.maxHeight;
    heightMorph = Tween(begin: totalHeight, end: heightEnd).animate(
        CurvedAnimation(parent: controller, curve: Curves.linear));

    BoxDecoration decoration = loaderContainer.decoration;
    colorMorph = ColorTween(begin: widget.backgroundColor, end: decoration.color).animate(
        CurvedAnimation(parent: controller, curve: Curves.linear));

    radiusMorph = BorderRadiusTween(begin: BorderRadius.all(Radius.circular(totalHeight/2)), end: decoration.borderRadius).animate(
      CurvedAnimation(parent: controller, curve: Curves.linear));


    // Configure the controller so the loader animation starts when it finishes
    controller.addStatusListener((status){
      if (status == AnimationStatus.completed)
        widget.loaderAnimation.startLoadingAnimation();
    });
    super.initState();
  }
  
  void startAnimation() async {
    controller.forward();
  }

  Future<int> finishAnimation() async {
    return await widget.loaderAnimation.finishLoadingAnimation();
  }

  @override
  Widget build(BuildContext context) {
    Color textColor = widget.text.style.color.withOpacity(fadeText.value);
    Text fadedText = Text(widget.text.data, style: widget.text.style.copyWith(color: textColor));
    return GestureDetector(
      onTap: startAnimation,
      child: new Container(
        width: widthMorph.value,
        height: heightMorph.value,
        child: fadeText.value > 0 ? Padding(
          padding: widget.padding,
          child: fadedText
        ) : null,
        alignment: FractionalOffset.center,
        decoration: new BoxDecoration(
          color: colorMorph.value,
          borderRadius: radiusMorph.value,
        ),
      ),
    );
    /*
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
*/
  }
}