/**
 * PLEASE
 * Do not look in this file.
 *
 * This is the largest collection of hacked together strings of double math and poor naming convention.
 * The paint accessory methods are kind of okay, but DO NOT look at the main paint method.
 * This chocolate bar animation has been performed using **linear mapping** instead of tweens or any thing like that
 * and it is the result of my blood, sweat, and tears over multiple months.  It is the biggest plate of spaghetti known
 * to man.
 *
 * FOR YOUR OWN SAFETY, DO NOT ENTER
 *
 * (Poorly) Written by: Theo Grossberndt
 */
import 'package:flutter/material.dart';
import 'package:bodt_chat/loaders/chocolateLoader/chocolateLoaderWidget.dart';

class BarPainter extends CustomPainter {
  ChocolateLoaderWidget widget;
  double value, slope;
  double padding = 10.0;

  BarPainter({@required this.widget, @required this.value}):
      slope = (2 * widget.squareHeight) / (5 * widget.squareWidth);

  void paintSquare([Canvas canvas, double fade = 1.0]){
    if (fade < 0.0)
      fade = 0.0;
    Paint paint = Paint()
      ..style = PaintingStyle.fill
      ..strokeWidth = 0.0;

    Rect baseRect = Rect.fromLTWH(0.0, 0.0, widget.squareWidth, widget.squareHeight);
    canvas.drawRect(baseRect, paint..color = widget.baseColor.withOpacity(fade));

    double baseW = widget.squareWidth - 2 * widget.inset;
    double topW = baseW - 2 * widget.elevation;
    double baseH = widget.squareHeight - 2 * widget.inset;
    double rightH = baseH - 2 * widget.elevation;

    double hw = widget.elevation;

    Path topTrap = horizontalTrapezoid(widget.inset, widget.inset, baseW, topW, hw);
    Path rightTrap = verticalTrapezoid(widget.inset, widget.inset, baseH, rightH, hw);
    Path bottomTrap = horizontalTrapezoid(widget.inset, widget.squareHeight - widget.inset, baseW, topW, -1 * hw);
    Path leftTrap = verticalTrapezoid(widget.squareWidth - widget.inset, widget.inset, baseH, rightH, -1 * hw);

    canvas.drawPath(topTrap, paint..color = widget.middleEdgeColor.withOpacity(fade));
    canvas.drawPath(rightTrap, paint..color = widget.darkEdgeColor.withOpacity(fade));
    canvas.drawPath(bottomTrap, paint..color = widget.darkEdgeColor.withOpacity(fade));
    canvas.drawPath(leftTrap, paint..color = widget.lightEdgeColor.withOpacity(fade));

    Rect elevatedRect = new Rect.fromLTRB(
        widget.inset + widget.elevation,
        widget.inset + widget.elevation,
        widget.squareWidth - widget.inset - widget.elevation,
        widget.squareHeight - widget.inset - widget.elevation);

    LinearGradient gradient = LinearGradient(
      begin: Alignment.topRight,
      end: Alignment.bottomLeft,
      colors: [widget.elevatedColor.withOpacity(fade), Color.lerp(widget.elevatedColor.withOpacity(fade), widget.darkEdgeColor.withOpacity(fade), 0.25)],
    );

    canvas.drawRect(elevatedRect, paint..shader = gradient.createShader(elevatedRect));
  }

  void paintBar(Canvas canvas, int width, int height){
    for (int y = 0; y < height; y++) {
      for (int x = 0; x < width; x++) {
        paintSquare(canvas);
        canvas.translate(widget.squareWidth, 0.0);
      }

      canvas.translate(-1 * width * widget.squareWidth, widget.squareHeight);
    }

    canvas.translate(0.0, -1 * height * widget.squareHeight);
  }
  
  
  // The cut should pass through the bottom left corner of the piece at the 2nd row, 5th column
  // and have a slope of 3/5
  // Draw as many rows as are needed, and then lop off everything above this line -- Not true any more
  void paintBottomSection(Canvas canvas, double startX, double startY, double endX, double endY){
    double bottomY = widget.squareHeight * widget.heightCount;

    Path keeper = Path()
      ..moveTo(0.0, bottomY)
      ..lineTo(startX, startY)
      ..lineTo(endX, endY)
      ..lineTo(endX, bottomY)
      ..close();

    canvas.clipPath(keeper);
    paintBar(canvas, widget.widthCount, widget.heightCount);
  }

  // Do pretty much the same thing as the bottom section, but paint a different part
  // Also, paint an additional growHeight down from the line
  void paintMiddleLeftSection(Canvas canvas, double startX, double startY, double growHeight){
    // Only paint the section from (startX, startY) to (startX, startY) up by 2 and over by 3
    double endX = widget.squareWidth * 3;
    double endY = startY - endX * slope;

    Path keeper = new Path()
      ..moveTo(startX, startY + growHeight)
      ..lineTo(endX, endY + growHeight)
      ..lineTo(endX, widget.squareHeight)
      ..lineTo(startX, widget.squareHeight)
      ..close();

    canvas.clipPath(keeper);
    paintBar(canvas, widget.widthCount, widget.heightCount);
  }

  void paintRightSection(Canvas canvas, double startX, double startY, double endX, double endY, double growHeight){
    // Only paint the section from (startX, startY) up by 1 and over by 3 to (endX, endY)
    double newStartX = widget.squareWidth * 3;
    double newStartY = startY - newStartX * slope;

    Path keeper = new Path()
      ..moveTo(newStartX, newStartY + growHeight)
      ..lineTo(endX, endY + growHeight)
      ..lineTo(endX, 0.0)
      ..lineTo(newStartX, 0.0)
      ..close();

    canvas.clipPath(keeper);
    paintBar(canvas, widget.widthCount, widget.heightCount);
  }

  void paintTopMiddleSection(Canvas canvas){
    Rect keeper = new Rect.fromLTWH(widget.squareWidth, 0.0, widget.squareWidth*2, widget.squareHeight);
    canvas.clipRect(keeper);
    paintBar(canvas, widget.widthCount, widget.heightCount);
  }

  @override
  void paint(Canvas canvas, Size size) {
    canvas.translate(widget.squareWidth * widget.widthCount * -0.5, widget.squareHeight * widget.heightCount * -0.5);

    // Compute some points dealing with the main line of separation
    double bottomY = widget.squareHeight * widget.heightCount;

    // It passes through the bottom left corner of (5, 4)
    double middleX = widget.squareWidth * 4;
    double middleY = bottomY - widget.squareHeight * 3;

    // There is a line y = .6 * x + b that passes through there
    // Compute b for that line
    double startX = 0.0;
    double startY = middleY + middleX * slope;

    // Now compute the point (endX, endY) from this line, given endX
    double endX = widget.squareWidth * widget.widthCount;
    double endY = startY - endX * slope;

    canvas.save();
    paintBottomSection(canvas, startX, startY, endX, endY);
    canvas.restore();

//    value = 1.0;

    canvas.save();
    double midLeftSepMax = widget.squareHeight / 5;

    double leftMotionEnd = 0.4;
    double leftVertSep = map(value, 0.0, 0.25, 0.0, midLeftSepMax);
    double growHeight = map(value, 0.25, leftMotionEnd, 0.0, midLeftSepMax);
    double leftTravel = map(value, 0.25, leftMotionEnd, 0.0, widget.squareWidth * 2);

    canvas.translate(leftTravel, -1 * leftVertSep - leftTravel * slope);

    paintMiddleLeftSection(canvas, startX, startY, growHeight);
    canvas.restore();

    canvas.save();
    double dropDownEnd = 0.7;
    double rightSepMax = widget.squareHeight * 3 + padding * 2 + slope * widget.squareWidth;

    double rightVertSep = map(value, 0.0, 0.25, 0.0, rightSepMax);
    double dropSep = map(value, leftMotionEnd, dropDownEnd, 0.0, rightSepMax + widget.squareHeight);
    growHeight = map(value, 0.25, dropDownEnd, 0.0, midLeftSepMax);
    double rightTravel = map(value, 0.25, leftMotionEnd, 0.0, widget.squareWidth * 3);

    canvas.translate(-1 * rightTravel, -1 * rightVertSep + dropSep);

    paintRightSection(canvas, startX, startY - 0*widget.squareHeight, endX, endY, growHeight);
    canvas.restore();

    canvas.save();

    double fadeMoveSplit = 0.85;

    double moveRight = map(value, 0.25, leftMotionEnd, 0.0, widget.squareWidth);
    double increasePadding = map(value, 0.0, 0.25, 0.0, padding);
    // Start moving back once the (dropSep + widget.squareHeight * 2 + widget.squareWidth * slope) passes the bottom edge
    // dropSep maps linearly from [0.5, 0.75] to [0.0, rightSepMax + widget.squareHeight]
    // We want to know when it will map to (leftVertSep_max + leftTravel_max * slope + increasePadding_max)
    double dropYPos = (midLeftSepMax + widget.squareWidth * 2 * slope + padding * 2) + (widget.squareHeight * 2 + widget.squareWidth * slope);
    double dropSepPassTime = (((dropYPos + leftMotionEnd) * (dropDownEnd - leftMotionEnd)) / (rightSepMax + widget.squareHeight) + leftMotionEnd);
    double dropSepPassTimeMid = (fadeMoveSplit - dropSepPassTime) / 2 + dropSepPassTime;
    double moveBack = map(value, dropSepPassTime, dropSepPassTimeMid, 0.0, widget.squareWidth*2);
    double drop = map(value, dropSepPassTimeMid, fadeMoveSplit, 0.0, widget.squareHeight + padding);

    canvas.translate(moveRight - moveBack, -1 * leftVertSep - leftTravel * slope - increasePadding + drop);
    paintTopMiddleSection(canvas);
    canvas.restore();

    canvas.save();
    double moveLeft = map(value, 0.0, 0.1, 0.0, widget.squareWidth + padding);
    double moveDown = map(value, 0.1, 0.25, 0.0, widget.squareHeight + padding);
    double fade = map(value, fadeMoveSplit, 1.0, 0.0, 100.0);
    canvas.translate(-1 * moveLeft, moveDown - leftVertSep - increasePadding);
    paintSquare(canvas, 1.0 - fade/100.0);
    canvas.restore();
  }

  double map(double input, double inMin, double inMax, double outMin, double outMax){
    if (input > inMax)
      return outMax;
    if (input < inMin)
      return outMin;
    return inMin + ((outMax - outMin) / (inMax - inMin)) * (input - inMin);
  }

  @override
  bool shouldRepaint(BarPainter oldDelegate) => value != oldDelegate.value;


  // The point (x, y) should be the bottom left point of the trapezoid, or top left if height is negative
  static Path horizontalTrapezoid(double x, double y, double baseW, double topW, double height){
    assert(baseW > topW);
    double xStep = (baseW - topW)/2;
    return Path()
      ..moveTo(x, y)
      ..relativeLineTo(xStep, height)
      ..relativeLineTo(topW, 0.0)
      ..relativeLineTo(xStep, -1 * height)
      ..close();
  }

  // The point (x, y) should be the top left point of the trapezoid, or top right if width is negative
  static Path verticalTrapezoid(double x, double y, double baseH, double rightH, double width){
    assert(baseH > rightH);
    double yStep = (baseH - rightH)/2;
    return Path()
      ..moveTo(x, y)
      ..relativeLineTo(width, yStep)
      ..relativeLineTo(0.0, rightH)
      ..relativeLineTo(-1 * width, yStep)
      ..close();
  }
}