import 'dart:async';
import 'package:flutter/material.dart';
import 'package:bodt_chat/constants.dart';
import 'package:bodt_chat/loaders/loader.dart';

class AnimatedLoadingButton<T extends Widget> extends StatefulWidget {
  final Text text;
  final T loaderAnimation;
  final Color backgroundColor;
  final Duration _morphDuration;
  final double fadeTextPortion;
  final EdgeInsets padding;
  final Function onClick;

  AnimatedLoadingButton({GlobalKey key, @required this.text, @required this.loaderAnimation, @required this.backgroundColor,
    Duration morphDuration,
    this.fadeTextPortion = LoadingButtonConstants.kBUTTON_FADE_TEXT_PORTION,
    this.padding = LoadingButtonConstants.kBUTTON_PADDING,
    this.onClick}):
      _morphDuration = morphDuration ?? Duration(milliseconds: LoadingButtonConstants.kBUTTON_MORPH_DURATION),
      assert(loaderAnimation is Loader || loaderAnimation == null),
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
    fadeText = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: controller.view, curve: Interval(0.0, widget.fadeTextPortion)));

    // These need the loader's container and the button's initial container
    TextSpan span = TextSpan(text: widget.text.data, style: widget.text.style);
    TextPainter buttonText = TextPainter(text: span, textDirection: TextDirection.ltr);
    buttonText.layout();
    textHeight = buttonText.height;
    textWidth = buttonText.width;
    
    totalHeight = textHeight + widget.padding.top + widget.padding.bottom;
    totalWidth = textWidth + widget.padding.left + widget.padding.right;

    Container loaderContainer = widget.loaderAnimation == null ? null :
        (widget.loaderAnimation as Loader).getSingleBaseContainer();

    double widthEnd = loaderContainer == null ? totalWidth : loaderContainer.constraints.maxWidth;
    widthMorph = Tween(begin: totalWidth, end: widthEnd).animate(
        CurvedAnimation(parent: controller.view, curve: Curves.linear));

    double heightEnd = loaderContainer == null ? totalHeight : loaderContainer.constraints.maxHeight;
    heightMorph = Tween(begin: totalHeight, end: heightEnd).animate(
        CurvedAnimation(parent: controller.view, curve: Curves.linear));

    BoxDecoration decoration = loaderContainer == null ? null : loaderContainer.decoration;
    Color endColor = loaderContainer == null ? widget.backgroundColor : decoration.color;
    colorMorph = ColorTween(begin: widget.backgroundColor, end: endColor).animate(
        CurvedAnimation(parent: controller.view, curve: Curves.linear));

    BorderRadius endRadius = loaderContainer == null ? BorderRadius.all(Radius.circular(totalHeight/2)) : decoration.borderRadius;
    radiusMorph = BorderRadiusTween(begin: BorderRadius.all(Radius.circular(totalHeight/2)), end: endRadius).animate(
      CurvedAnimation(parent: controller.view, curve: Curves.linear));


    // Configure the controller so the loader animation starts when it finishes
    controller.addStatusListener((status){
      if (status == AnimationStatus.completed){
        setState(() {
        });
      }
    });
    super.initState();
  }
  
  void startAnimation() async {
    widget.onClick();
    controller.forward();
  }

  Future<int> finishAnimation() async {
    if (widget.loaderAnimation != null && (widget.loaderAnimation.key as GlobalKey).currentWidget != null)
      return await ((widget.loaderAnimation.key as GlobalKey).currentWidget as Loader).finishLoadingAnimation();
    controller.reverse();
    while (controller.value > 0){}
    return 0;
  }

  Widget buildButton(BuildContext context, Widget child){
    Color textColor = widget.text.style.color.withOpacity(fadeText.value);
    Text fadedText = Text(widget.text.data, style: widget.text.style.copyWith(color: textColor));

    return Container(
      width: widthMorph.value,
      height: heightMorph.value,
      child: fadeText.value > 0 ? Padding(
          padding: widget.padding,
          child: Center(child: fadedText)
      ) : null,
      alignment: FractionalOffset.center,
      decoration: new BoxDecoration(
        color: colorMorph.value,
        borderRadius: radiusMorph.value,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (controller.status != AnimationStatus.completed || widget.loaderAnimation == null) {
      print(controller.value);
      return GestureDetector(
        onTap: controller.status == AnimationStatus.forward ? null : startAnimation,
        child: AnimatedBuilder(
            animation: controller,
            builder: buildButton
        ),
      );
    }

    if (!(widget.loaderAnimation as Loader).hasAnimated)
      (widget.loaderAnimation as Loader).startLoadingAnimation();
    return widget.loaderAnimation;
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}