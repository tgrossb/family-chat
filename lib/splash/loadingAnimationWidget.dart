import 'dart:math' as math;

import 'package:bodt_chat/constants.dart';
import 'package:bodt_chat/utils.dart';
import 'package:flutter/animation.dart';
import 'package:flutter/material.dart';

class LoadingAnimationWidget extends AnimatedWidget {
  final int count;
  LoadingAnimationWidget({Key key, @required Animation<double> animation, @required this.count}): super(key: key, listenable: animation);

  @override
  Widget build(BuildContext context) {
    final Animation<double> animation = listenable;
    double angle = animation.value;
    if (count == kLOADING_FINISH && angle > math.pi) angle = 0.0;
    return Transform.rotate(
        angle: angle, child: buildBasic(animation, context));
  }

  // A row where the middle dot moves up and down
  // Used on top and bottom rows
  Widget animatedMiddleToFigureCenterRow(
      [Animation<double> animation,
      Function activatorFunction = Utils.flippedLongCos,
      int m = 1]) {
    double dy = activatorFunction(animation.value) *
        m *
        kLOADING_H_MULT *
        (kLOADING_DIAMETER + 2 * kLOADING_PADDING);
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        simpleCircle(kLOADING_DIAMETER),
        Transform.translate(
            offset: Offset(0.0, dy), child: simpleCircle(kLOADING_DIAMETER)),
        simpleCircle(kLOADING_DIAMETER)
      ],
    );
  }

  // A row where the outer dots move to the center of the row
  // Used on middle row
  Widget animatedOuterToRowCenterRow(
      [Animation<double> animation,
      Function activatorFunction = Utils.flippedLongCos,
      int m = 1]) {
    double dx = activatorFunction(animation.value) *
        m *
        kLOADING_H_MULT *
        (kLOADING_DIAMETER + 2 * kLOADING_PADDING);
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Transform.translate(
            offset: Offset(dx, 0.0), child: simpleCircle(kLOADING_DIAMETER)),
        simpleCircle(kLOADING_DIAMETER),
        Transform.translate(
            offset: Offset(-1 * dx, 0.0),
            child: simpleCircle(kLOADING_DIAMETER)),
      ],
    );
  }

  // A row where the outer dots move to the center of the figure
  // Used on top and bottom rows
  Widget animatedOuterToFigureCenterRow(
      [Animation<double> animation,
      Function activatorFunction = Utils.flippedLongCos,
      int m = 1]) {
    double dxy = activatorFunction(animation.value) *
        kLOADING_H_MULT *
        (kLOADING_DIAMETER + 2 * kLOADING_PADDING);
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Transform.translate(
            offset: Offset(dxy, m * dxy),
            child: simpleCircle(kLOADING_DIAMETER)),
        simpleCircle(kLOADING_DIAMETER),
        Transform.translate(
            offset: Offset(-dxy, m * dxy),
            child: simpleCircle(kLOADING_DIAMETER)),
      ],
    );
  }

  // A row where each dot moves to the center of the figure
  // Used on top and bottom rows
  Widget animatedAllToFigureCenterRow(
      [Animation<double> animation,
      Function activatorFunction = Utils.flippedLongCos,
      int m = 1]) {
    double dxy = activatorFunction(animation.value) *
        kLOADING_H_MULT *
        (kLOADING_DIAMETER + 2 * kLOADING_PADDING);
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Transform.translate(
            offset: Offset(dxy, m * dxy),
            child: simpleCircle(kLOADING_DIAMETER)),
        Transform.translate(
            offset: Offset(0.0, m * dxy),
            child: simpleCircle(kLOADING_DIAMETER)),
        Transform.translate(
            offset: Offset(-dxy, m * dxy),
            child: simpleCircle(kLOADING_DIAMETER)),
      ],
    );
  }

  // A simple, non-animated row
  Widget basicRow() {
    return new Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        simpleCircle(kLOADING_DIAMETER),
        simpleCircle(kLOADING_DIAMETER),
        simpleCircle(kLOADING_DIAMETER)
      ],
    );
  }

  Widget buildCollapsingState(
      [Animation<double> animation,
      Function activatorFunction = Utils.flippedLongCos]) {
    return new Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        animatedAllToFigureCenterRow(animation, activatorFunction),
        animatedOuterToRowCenterRow(animation, activatorFunction),
        animatedAllToFigureCenterRow(animation, activatorFunction, -1),
      ],
    );
  }

  Widget buildAnimatedMiddlesState(
      [Animation<double> animation,
      Function activatorFunction = Utils.flippedLongCos]) {
    return new Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        animatedMiddleToFigureCenterRow(animation, activatorFunction),
        animatedOuterToRowCenterRow(animation, activatorFunction),
        animatedMiddleToFigureCenterRow(animation, activatorFunction, -1),
      ],
    );
  }

  Widget buildAnimatedCornersState(
      [Animation<double> animation,
      Function activatorFunction = Utils.flippedLongCos]) {
    return new Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        animatedOuterToFigureCenterRow(animation, activatorFunction),
        basicRow(),
        animatedOuterToFigureCenterRow(animation, activatorFunction, -1),
      ],
    );
  }

  Widget buildCollapseThenExpandState(
      Animation<double> animation, BuildContext context) {
    return animation.value < math.pi
        ? buildCollapsingState(animation)
        : new Center(
            child: Transform.scale(
                scale: Utils.scaleToBig(animation.value),
                child: simpleCircle(kLOADING_DIAMETER)));
    // TODO: Fix this to use the custom painter (current problem is then painter doesn't animate?)
/*
        new Container(
//        tag: "circleOut",
            child: CustomPaint(
                painter: CircleOutPainter(
                    value: animation.value,
                    size: MediaQuery.of(context).size,
                    color: kSPLASH_SCREEN_LOADING_COLOR,
                    initialDiameter: kLOADING_DIAMETER
                )
            )
        );
*/
  }

  Widget buildBasic(Animation<double> animation, BuildContext context) {
    if (count == kLOADING_FINISH)
      return buildCollapseThenExpandState(animation, context);
    if (count % 3 == 0)
      return buildAnimatedMiddlesState(animation);
    else if (count % 3 == 1)
      return buildAnimatedCornersState(animation);
    else if (count % 3 == 2) return buildCollapsingState(animation);
    return simpleCircle(kLOADING_DIAMETER);
  }

  Widget simpleCircle(double diameter) {
    return Padding(
        padding: EdgeInsets.all(kLOADING_PADDING),
        child: Container(
          width: diameter,
          height: diameter,
          decoration: BoxDecoration(
            color: kSPLASH_SCREEN_LOADING_COLOR,
            shape: BoxShape.circle,
          ),
        ));
  }
}

class CircleOutPainter extends CustomPainter {
  final double finalRadius;
  double value, initialDiameter;
  Size size;
  Color color;

  CircleOutPainter({this.value, this.size, this.color, this.initialDiameter})
      : finalRadius = math.sqrt(math.pow(size.width / 2, 2)) +
            math.pow(size.height / 2, 2);

  @override
  void paint(Canvas canvas, Size sz) {
    Paint paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    double r = initialDiameter / 2 + (math.cos(value) * finalRadius);
    canvas.drawCircle(Offset.zero, r, paint);
  }

  @override
  bool shouldRepaint(CircleOutPainter oldDelegate) {
    return oldDelegate.value != value;
  }
}
