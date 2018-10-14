/**
 * This is the main class of the infinite chocolate bar loading animation.
 * The actual painting part can be found in ./barPainter.dart (read the warning).
 * The animated widget wrapper for the painter is factored into its own class at ./chocolateLoaderAnimation.dart.
 */
import 'dart:async';
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
    this.inset = ChocolateConstants.kCHOCOLATE_INSET,
    this.elevation = ChocolateConstants.kCHOCOLATE_ELEVATION,
    this.squareWidth = ChocolateConstants.kCHOCOLATE_SQUARE_WIDTH,
    this.squareHeight = ChocolateConstants.kCHOCOLATE_SQUARE_HEIGHT,
    this.widthCount = ChocolateConstants.kCHOCOLATE_WIDTH_COUNT,
    this.heightCount = ChocolateConstants.kCHOCOLATE_HEIGHT_COUNT,
    this.baseColor = ChocolateConstants.kCHOCOLATE_BASE_COLOR,
    this.elevatedColor = ChocolateConstants.kCHOCOLATE_ELEVATED_COLOR,
    this.darkEdgeColor = ChocolateConstants.kCHOCOLATE_DARK_EDGE_COLOR,
    this.lightEdgeColor = ChocolateConstants.kCHOCOLATE_LIGHT_EDGE_COLOR,
    this.middleEdgeColor = ChocolateConstants.kCHOCOLATE_MIDDLE_EDGE_COLOR,
    Duration duration}):
        _duration = duration ?? Duration(milliseconds: ChocolateConstants.kCHOCOLATE_DURATION),
        super(key: key ?? GlobalKey());

  @override
  Container getSingleBaseContainer() => Container(
    width: squareWidth * widthCount,
    height: squareHeight * heightCount,
    color: baseColor,
  );

  @override
  void startLoadingAnimation() async {
    while ((super.key as GlobalKey).currentState == null){}
    ((super.key as GlobalKey).currentState as ChocolateLoaderWidgetState).startLoadingAnimation();
  }

  @override
  Future<int> finishLoadingAnimation() async {
    return await ((super.key as GlobalKey).currentState as ChocolateLoaderWidgetState).finishLoadingAnimation();
  }

  @override
  get hasAnimated => (super.key as GlobalKey).currentState == null ? false :
    ((super.key as GlobalKey).currentState as ChocolateLoaderWidgetState).hasAnimated;

  @override
  State<StatefulWidget> createState() => ChocolateLoaderWidgetState();
}

class ChocolateLoaderWidgetState extends State<ChocolateLoaderWidget> with SingleTickerProviderStateMixin {
  AnimationController controller;
  Animation<double> animation;
  bool finishing = false, hasAnimated = false;

  @override
  void initState() {
    super.initState();

    // Set up the animation controller
    controller = new AnimationController(vsync: this, duration: widget._duration);
    animation = Tween(begin: 0.0, end: 1.0).animate(controller);

    // Set the controller to repeat when finished
    controller.addStatusListener((AnimationStatus status) {
      if (status == AnimationStatus.completed && !finishing)
        controller.forward(from: 0.0);
    });
  }

  void startLoadingAnimation() {
    controller.forward();
    hasAnimated = true;
  }

  Future<int> finishLoadingAnimation() async {
    // Don't just stop the controller, set the flag that it should finish, and then return 0 once it does
    setState(() {
      finishing = true;
    });

    while (controller.status != AnimationStatus.completed){}

    return 0;
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