import 'dart:math' as math;
import 'dart:async';

import 'package:bodt_chat/constants.dart';
import 'package:flutter/animation.dart';
import 'package:flutter/material.dart';
import 'package:bodt_chat/loaders/loader.dart';
import 'package:bodt_chat/loaders/dotMatrixLoader/dotMatrixLoaderAnimation.dart';
import 'package:bodt_chat/loaders/dotMatrixLoader/dotMatrixFromContainerWidget.dart';

class DotMatrixLoaderWidget extends StatefulWidget implements Loader {
  final double padding, diameter, hMult;
  final Color color;
  final Duration _duration, _fromContainerDuration;

  DotMatrixLoaderWidget({GlobalKey key,
    this.padding = DotConstants.kDOT_PADDING,
    this.diameter = DotConstants.kDOT_DIAMETER,
    this.color = DotConstants.kDOT_COLOR,
    this.hMult = DotConstants.kDOT_H_MULT,
    Duration duration,
    Duration fromContainerDuration}):
      _duration = duration ?? Duration(milliseconds: DotConstants.kDOT_DURATION),
      _fromContainerDuration = fromContainerDuration ?? Duration(milliseconds: DotConstants.kDOT_FROM_CONTAINER_DURATION),
      super(key: key ?? GlobalKey());

  @override
  Container getSingleBaseContainer() => Container(
    width: diameter * 3 + padding * 4,
    height: diameter * 3 + padding * 4,
    color: color,
  );

  @override
  void startLoadingAnimation() async {
    while ((super.key as GlobalKey).currentState == null){}
    ((super.key as GlobalKey).currentState as DotMatrixLoaderWidgetState).startLoadingAnimation();
  }

  @override
  Future<int> finishLoadingAnimation() async {
    return await ((super.key as GlobalKey).currentState as DotMatrixLoaderWidgetState).finishLoadingAnimation();
  }

  @override
  get hasAnimated => (super.key as GlobalKey).currentState == null ? false :
  ((super.key as GlobalKey).currentState as DotMatrixLoaderWidgetState).hasAnimated;

  @override
  State<StatefulWidget> createState() => DotMatrixLoaderWidgetState();

  get fromContainerDuration => _fromContainerDuration;
}

class DotMatrixLoaderWidgetState extends State<DotMatrixLoaderWidget> with TickerProviderStateMixin {
  AnimationController fromContainerController, controller;
  Animation dotRadiusAnimation, dotDiameterAnimation, animation;
  bool finishing = false, hasAnimated = false;
  GlobalKey fromContainerWidget = GlobalKey();
  int loopCounter = 0;

  @override
  void initState() {
    // Set up the animation
    controller = AnimationController(vsync: this, duration: widget._duration);
    animation = Tween(begin: 0.0, end: math.pi * 2).animate(controller);

    // Repeat the controller when it finishes and increment the counter
    controller.addStatusListener((AnimationStatus status){
      if (status == AnimationStatus.completed && !finishing) {
        controller.forward(from: 0.0);
        setState(() {
          loopCounter++;
        });
      }
    });

    super.initState();
  }

  void startLoadingAnimation() async {
    // First, show the animation going from the singleBaseContainer to the start state
    while (fromContainerWidget.currentWidget == null){}

    (fromContainerWidget.currentWidget as DotMatrixFromContainerWidget).startAnimation();
    hasAnimated = true;
  }

  Future<int> finishLoadingAnimation() async {
    setState(() {
      finishing = true;
    });

    while (controller.status != AnimationStatus.completed){}

    return 0;
  }

  @override
  Widget build(BuildContext context) {
    if (controller.status == AnimationStatus.forward)
      return DotMatrixLoaderAnimation(animation: animation, widget: widget, loopCounter: loopCounter);

    return DotMatrixFromContainerWidget(key: fromContainerWidget, loaderWidget: widget, finishedCallback: (){
      setState(() {
        controller.forward();
      });
    });
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}