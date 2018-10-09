import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:bodt_chat/loaders/loader.dart';
import 'package:bodt_chat/loaders/chocolateLoader/chocolateLoaderAnimation.dart';
import 'package:bodt_chat/constants.dart';

class ChocolateLoaderWidget extends StatefulWidget implements Loader {
  final double inset, elevation, squareWidth, squareHeight;
  final int widthCount, heightCount;
  final Color baseColor, elevatedColor, darkEdgeColor, lightEdgeColor, middleEdgeColor;
  final Duration _duration;

  ChocolateLoaderWidget({GlobalKey key,
    this.inset = kCHOCOLATE_INSET,
    this.elevation = kCHOCOLATE_ELEVATION,
    this.squareWidth = kCHOCOLATE_SQUARE_WIDTH,
    this.squareHeight = kCHOCOLATE_SQUARE_HEIGHT,
    this.widthCount = kCHOCOLATE_WIDTH_COUNT,
    this.heightCount = kCHOCOLATE_HEIGHT_COUNT,
    this.baseColor = kCHOCOLATE_BASE_COLOR,
    this.elevatedColor = kCHOCOLATE_ELEVATED_COLOR,
    this.darkEdgeColor = kCHOCOLATE_DARK_EDGE_COLOR,
    this.lightEdgeColor = kCHOCOLATE_LIGHT_EDGE_COLOR,
    this.middleEdgeColor = kCHOCOLATE_MIDDLE_EDGE_COLOR,
    Duration duration}):
        _duration = duration ?? Duration(milliseconds: kCHOCOLATE_DURATION),
        super(key: key ?? GlobalKey());

  @override
  Container getSingleBaseContainer() =>
      ((super.key as GlobalKey).currentState as Loader).getSingleBaseContainer();

  @override
  void startLoadingAnimation() async {
    while ((super.key as GlobalKey).currentState == null){}
    ((super.key as GlobalKey).currentState as Loader).startLoadingAnimation();
  }

  @override
  State<StatefulWidget> createState() => ChocolateLoaderWidgetState();
}

class ChocolateLoaderWidgetState extends State<ChocolateLoaderWidget> with SingleTickerProviderStateMixin implements Loader {
  AnimationController controller;
  Animation<double> animation;

  @override
  void initState() {
    super.initState();

    // Set up the animation controller
    controller = new AnimationController(vsync: this, duration: widget._duration);
    animation = Tween(begin: 0.0, end: 1.0).animate(controller);

    // Set the controller to repeat when finished
    controller.addStatusListener((AnimationStatus status) {
      if (status == AnimationStatus.completed)
        controller.forward(from: 0.0);
    });
  }

  @override
  Container getSingleBaseContainer() =>
      Container(
        width: widget.squareWidth * widget.widthCount,
        height: widget.squareHeight * widget.heightCount,
        color: widget.baseColor,
      );

  @override
  void startLoadingAnimation() {
    controller.forward();
  }

  @override
  Widget build(BuildContext context) {
    return ChocolateLoaderAnimation(animation: animation, widget: widget);
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}