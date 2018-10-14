import 'dart:math' as math;
import 'dart:async';

import 'package:bodt_chat/constants.dart';
import 'package:flutter/animation.dart';
import 'package:flutter/material.dart';
import 'package:bodt_chat/loaders/loader.dart';
import 'package:bodt_chat/loaders/dotMatrixLoader/dotMatrixLoaderAnimation.dart';

class DotMatrixLoaderWidget extends StatefulWidget implements Loader {
  final double padding, diameter, hMult;
  final Color color;
  final Duration _duration;

  DotMatrixLoaderWidget({GlobalKey key,
    this.padding = DotConstants.kDOT_PADDING,
    this.diameter = DotConstants.kDOT_DIAMETER,
    this.color = DotConstants.kDOT_COLOR,
    this.hMult = DotConstants.kDOT_H_MULT,
    Duration duration}):
      _duration = duration ?? Duration(milliseconds: DotConstants.kDOT_DURATION),
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
  State<StatefulWidget> createState() => DotMatrixLoaderWidgetState();
}

class DotMatrixLoaderWidgetState extends State<DotMatrixLoaderWidget> with SingleTickerProviderStateMixin {
  AnimationController controller;
  Animation animation;
  bool finishing = false;

  @override
  void initState() {
    // Set up the animation
    controller = AnimationController(vsync: this, duration: widget._duration);
    animation = Tween(begin: 0.0, end: math.pi * 2).animate(controller);

    // Repeat the controller when it finishes
    controller.addStatusListener((AnimationStatus status){
      if (status == AnimationStatus.completed && !finishing)
        controller.forward(from: 0.0);
    });

    super.initState();
  }

  void startLoadingAnimation() async {
    controller.forward();
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
    return DotMatrixLoaderAnimation(animation: animation, widget: widget);
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}