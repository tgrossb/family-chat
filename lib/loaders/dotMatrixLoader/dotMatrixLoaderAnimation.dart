import 'package:flutter/material.dart';
import 'package:bodt_chat/loaders/dotMatrixLoader/dotMatrixLoaderWidget.dart';
import 'package:bodt_chat/utils.dart';
import 'dart:math' as math;

class DotMatrixLoaderAnimation extends AnimatedWidget {
  final DotMatrixLoaderWidget widget;
  final int loopCounter;

  DotMatrixLoaderAnimation({Key key, @required Animation<double> animation, @required this.widget, @required this.loopCounter}):
      super(key: key, listenable: animation);

  @override
  Widget build(BuildContext context) {
    double angle = (listenable as Animation<double>).value;
    return Transform.rotate(angle: angle/2 + (loopCounter % 2 == 0 ? 0 : math.pi), child: buildBasic(angle, context));
  }

  // A row where the middle dot moves up and down
  // Used on top and bottom rows
  Widget animatedMiddleToFigureCenterRow([double value, Function activatorFunction = Utils.flippedLongCos, int m = 1]) {
    double dy = activatorFunction(value) * m * widget.hMult * (widget.diameter + 2 * widget.padding);
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        simpleCircle(widget.diameter),
        Transform.translate(
            offset: Offset(0.0, dy), child: simpleCircle(widget.diameter)),
        simpleCircle(widget.diameter)
      ],
    );
  }

  // A row where the outer dots move to the center of the row
  // Used on middle row
  Widget animatedOuterToRowCenterRow([double value, Function activatorFunction = Utils.flippedLongCos, int m = 1]) {
    double dx = activatorFunction(value) * m * widget.hMult * (widget.diameter + 2 * widget.padding);
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Transform.translate(
            offset: Offset(dx, 0.0), child: simpleCircle(widget.diameter)),
        simpleCircle(widget.diameter),
        Transform.translate(
            offset: Offset(-1 * dx, 0.0),
            child: simpleCircle(widget.diameter)),
      ],
    );
  }

  // A row where the outer dots move to the center of the figure
  // Used on top and bottom rows
  Widget animatedOuterToFigureCenterRow([double value, Function activatorFunction = Utils.flippedLongCos, int m = 1]) {
    double dxy = activatorFunction(value) * widget.hMult * (widget.diameter + 2 * widget.padding);
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Transform.translate(
            offset: Offset(dxy, m * dxy),
            child: simpleCircle(widget.diameter)),
        simpleCircle(widget.diameter),
        Transform.translate(
            offset: Offset(-dxy, m * dxy),
            child: simpleCircle(widget.diameter)),
      ],
    );
  }

  // A row where each dot moves to the center of the figure
  // Used on top and bottom rows
  Widget animatedAllToFigureCenterRow([double value, Function activatorFunction = Utils.flippedLongCos, int m = 1]) {
    double dxy = activatorFunction(value) * widget.hMult * (widget.diameter + 2 * widget.padding);
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Transform.translate(
            offset: Offset(dxy, m * dxy),
            child: simpleCircle(widget.diameter)),
        Transform.translate(
            offset: Offset(0.0, m * dxy),
            child: simpleCircle(widget.diameter)),
        Transform.translate(
            offset: Offset(-dxy, m * dxy),
            child: simpleCircle(widget.diameter)),
      ],
    );
  }

  // A simple, non-animated row
  Widget basicRow() {
    return new Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        simpleCircle(widget.diameter),
        simpleCircle(widget.diameter),
        simpleCircle(widget.diameter)
      ],
    );
  }

  Widget buildCollapsingState([double value, Function activatorFunction = Utils.flippedLongCos]) {
    return new Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        animatedAllToFigureCenterRow(value, activatorFunction),
        animatedOuterToRowCenterRow(value, activatorFunction),
        animatedAllToFigureCenterRow(value, activatorFunction, -1),
      ],
    );
  }

  Widget buildAnimatedMiddlesState([double value, Function activatorFunction = Utils.flippedLongCos]) {
    return new Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        animatedMiddleToFigureCenterRow(value, activatorFunction),
        animatedOuterToRowCenterRow(value, activatorFunction),
        animatedMiddleToFigureCenterRow(value, activatorFunction, -1),
      ],
    );
  }

  Widget buildAnimatedCornersState([double value, Function activatorFunction = Utils.flippedLongCos]) {
    return new Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        animatedOuterToFigureCenterRow(value, activatorFunction),
        basicRow(),
        animatedOuterToFigureCenterRow(value, activatorFunction, -1),
      ],
    );
  }

  Widget buildCollapseThenExpandState(
      Animation<double> animation, BuildContext context) {
    return animation.value < math.pi
        ? buildCollapsingState(animation.value)
        : new Center(
        child: Transform.scale(
            scale: Utils.scaleToBig(animation.value),
            child: simpleCircle(widget.diameter)));
    // TODO: Fix this to use the custom painter (current problem is then painter doesn't animate?)
/*
        new Container(
//        tag: "circleOut",
            child: CustomPaint(
                painter: CircleOutPainter(
                    value: animation.value,
                    size: MediaQuery.of(context).size,
                    color: kSPLASH_SCREEN_LOADING_COLOR,
                    initialDiameter: widget.diameter
                )
            )
        );
*/
  }

  Widget buildBasic(double value, BuildContext context) {
//    if (count == kLOADING_FINISH)
//      return buildCollapseThenExpandState(animation, context);

    if (loopCounter % 3 == 0)
      return buildAnimatedMiddlesState(value);
    else if (loopCounter % 3 == 1)
      return buildAnimatedCornersState(value);
    else
      return buildCollapsingState(value);
  }

  Widget simpleCircle(double diameter) {
    return Padding(
        padding: EdgeInsets.all(widget.padding),
        child: Container(
          width: diameter,
          height: diameter,
          decoration: BoxDecoration(
            color: widget.color,
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
