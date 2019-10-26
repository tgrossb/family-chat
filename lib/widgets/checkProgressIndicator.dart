/**
 * This widget is like the material circular progress indicator, except it can be stopped.
 * When stopped, it animates into a check mark.
 *
 * The toCheck state can be triggered with, you guessed it, a stream.
 * Just supply the finish stream and bring it high (send a 1) to trigger an end state.
 * CheckProgressIndicators cannot be reused.  Bringing the stream back low won't do anything.
 *
 * Written by: Theo Grossberndt
 */

import 'package:flutter/material.dart';
import 'dart:math';

class CheckProgressIndicator extends StatefulWidget {
  static const int FINISH = 1;

  final Color color;
  final double strokeWidth;
  final Stream<int> finish;
  final Duration duration;

  CheckProgressIndicator({@required this.color, this.strokeWidth = 1, this.finish, this.duration});

  @override
  State<CheckProgressIndicator> createState() => CheckProgressIndicatorState();
}

class CheckProgressIndicatorState extends State<CheckProgressIndicator> with SingleTickerProviderStateMixin {
  AnimationController _controller;

  bool toCheckNext = false;
  bool toCheck = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    _controller = AnimationController(vsync: this, duration: widget.duration ?? Duration(milliseconds: 750));

    _controller.addStatusListener((status){
      if (status == AnimationStatus.completed && !toCheck) {
        _controller.forward(from: 0);
        if (toCheckNext)
          setState((){
            toCheck = true;
          });
      }
    });

    _controller.forward();

    // Separate into toCheckNext and toCheck to ensure that the change happens on the controller restart
    // so the states of the rotation modifier and custom painter stay in sync
    if (widget.finish != null)
      widget.finish.listen((data){
        if (data == CheckProgressIndicator.FINISH){
          setState((){
            toCheckNext = true;
          });
        }
      });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child){
        return Transform.rotate(
          angle: (_controller.value < 0.5 || !toCheck) ? _controller.value * pi : 0,
          child: CustomPaint(
            painter: ProgressPainter(
                animation: _controller,
                color: widget.color,
                strokeWidth: widget.strokeWidth,
                toCheck: toCheck
            ),
          ),
        );
      },
    );
  }

  @override
  void dispose(){
    _controller.dispose();
    super.dispose();
  }
}

class ProgressPainter extends CustomPainter {
  final Animation<double> animation;
  final Color color;
  final double strokeWidth;
  final bool toCheck;
  ProgressPainter({@required this.animation, @required this.color, @required this.strokeWidth,
    @required this.toCheck});

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint();
    paint.color = color;
    paint.strokeWidth = strokeWidth;
    paint.style = PaintingStyle.stroke;
    double sweepAngle = sin(animation.value * pi) * pi;
    if (animation.value < 0.5)
      canvas.drawArc(Offset.zero & size, pi/2, sweepAngle, false, paint);
    else if (!toCheck) {
      canvas.drawArc(Offset.zero & size, 3 / 2 * pi - sweepAngle, sweepAngle, false, paint);
    } else {
      double offsetMult = min((animation.value - 0.5) * 4, 1);
      canvas.translate(-size.width/8 * offsetMult, -size.height/4 * offsetMult);

      canvas.drawArc(Offset.zero & size, -sweepAngle, sweepAngle, false, paint);
      Path p = Path();
      Offset rightSideRel = Offset(-size.width/2, size.height/2);
      Offset leftSideRel = Offset(-size.width/4, -size.height/4);
      double rsrDist = rightSideRel.distance;
      double lsrDist = leftSideRel.distance;
      double totalDist = rsrDist + lsrDist;
      double rsrFrac = rsrDist / totalDist;

      // Draw 1-sin(animation.value * pi) of the check mark
      double drawAmount = 1-sin(animation.value * pi);
      p.moveTo(size.width, size.height/2);
      if (drawAmount > rsrFrac){
        p.relativeLineTo(rightSideRel.dx, rightSideRel.dy);

        Offset leftSub = leftSideRel * (drawAmount - rsrFrac) / (1-rsrFrac);
        p.relativeLineTo(leftSub.dx, leftSub.dy);
      } else {
        Offset rightSub = rightSideRel * (drawAmount / rsrFrac);
        p.relativeLineTo(rightSub.dx, rightSub.dy);
      }
      canvas.drawPath(p, paint);
    }
  }

  @override
  bool shouldRepaint(ProgressPainter oldDelegate) {
    return animation.value < 1;
  }
}