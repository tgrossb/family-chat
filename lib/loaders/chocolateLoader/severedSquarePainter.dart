import 'package:flutter/material.dart';
import 'package:bodt_chat/loaders/chocolateLoader/chocolateLoaderWidget.dart';
import 'package:bodt_chat/constants.dart';

class SeveredSquarePainter extends CustomPainter {
  ChocolateLoaderWidget widget;
  Offset cutStart, cutEnd;
  double separation;

  SeveredSquarePainter({@required this.widget, @required this.cutStart, @required this.cutEnd, @required this.separation});

  @override
  void paint(Canvas canvas, Size size){
    double width = widget == null ? kCHOCOLATE_SQUARE_WIDTH : widget.squareWidth;
    double height = widget == null ? kCHOCOLATE_SQUARE_HEIGHT : widget.squareHeight;
    double inset = widget == null ? kCHOCOLATE_INSET : widget.inset;
    double elevation = widget == null ? kCHOCOLATE_ELEVATION : widget.elevation;
    Color baseColor = widget == null ? kCHOCOLATE_BASE_COLOR : widget.baseColor;
    Color darkEdgeColor = widget == null ? kCHOCOLATE_DARK_EDGE_COLOR : widget.darkEdgeColor;
    Color lightEdgeColor = widget == null ? kCHOCOLATE_LIGHT_EDGE_COLOR : widget.lightEdgeColor;
    Color middleEdgeColor = widget == null ? kCHOCOLATE_MIDDLE_EDGE_COLOR : widget.middleEdgeColor;
    Color elevatedColor = widget == null ? kCHOCOLATE_ELEVATED_COLOR : widget.elevatedColor;

    // Draw the base rectangle
    Paint paint = Paint()
      ..color = baseColor
      ..style = PaintingStyle.fill;

    Rect baseRect = Rect.fromLTWH(0.0, 0.0, width, height);

    canvas.drawRect(baseRect, paint);

    // Draw the shadow edges
    paint.color = darkEdgeColor;
    canvas.drawPath(leftTrapezoid(width, height, inset, elevation), paint);
    canvas.drawPath(bottomTrapezoid(width, height, inset, elevation), paint);

    // Draw the lightest edge
    paint.color = lightEdgeColor;
    canvas.drawPath(rightTrapezoid(width, height, inset, elevation), paint);

    // Draw the middle lightness edge
    paint.color = middleEdgeColor;
    canvas.drawPath(topTrapezoid(width, height, inset, elevation), paint);

    // Draw the elevated square
//    paint.color = elevatedColor;

    Rect elevatedRect = new Rect.fromLTRB(
        inset + elevation,
        inset + elevation,
        width - inset - elevation,
        height - inset - elevation);

    LinearGradient gradient = LinearGradient(
      begin: Alignment.topRight,
      end: Alignment.bottomLeft,
      colors: [elevatedColor, Color.lerp(elevatedColor, darkEdgeColor, 0.25)],
    );

    canvas.drawRect(elevatedRect, new Paint()..shader = gradient.createShader(elevatedRect));

    canvas.drawLine(cutStart, cutEnd, new Paint()..color = Colors.black);
  }

  static Color darken(Color color, double factor){
    int a = color.alpha;
    int r = (color.red * factor).round();
    int g = (color.green * factor).round();
    int b = (color.blue * factor).round();
    return Color.fromARGB(a, r < 255 ? r : 255, g < 255 ? g : 255, b < 255 ? b : 255);
  }

  static Path topTrapezoid(double width, double height, double inset, double elevation){
    return Path()
      ..moveTo(inset, inset)
      ..lineTo(width-inset, inset)
      ..lineTo(width-inset-elevation, inset+elevation)
      ..lineTo(inset+elevation, inset+elevation)
      ..close();
  }

  static Path bottomTrapezoid(double width, double height, double inset, double elevation){
    return Path()
      ..moveTo(inset, height-inset)
      ..lineTo(width-inset, height-inset)
      ..lineTo(width-inset-elevation, height-inset-elevation)
      ..lineTo(inset+elevation, height-inset-elevation)
      ..close();
  }

  static Path leftTrapezoid(double width, double height, double inset, double elevation){
    return Path()
      ..moveTo(inset, inset)
      ..lineTo(inset+elevation, inset+elevation)
      ..lineTo(inset+elevation, height-inset-elevation)
      ..lineTo(inset, height-inset)
      ..close();
  }

  static Path rightTrapezoid(double width, double height, double inset, double elevation){
    return Path()
      ..moveTo(width-inset, inset)
      ..lineTo(width-inset-elevation, inset+elevation)
      ..lineTo(width-inset-elevation, height-inset-elevation)
      ..lineTo(width-inset, height-inset)
      ..close();
  }

  @override
  bool shouldRepaint(SeveredSquarePainter oldDelegate) => false;
}