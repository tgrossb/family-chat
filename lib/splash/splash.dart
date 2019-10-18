import 'package:flutter/material.dart';
import 'dart:math';
import 'package:polygon_clipper/polygon_path_drawer.dart';
import 'package:polygon_clipper/polygon_clipper.dart';


class Splash extends StatefulWidget {
  Splash({Key key}) : super(key: key);

  @override
  SplashState createState() => SplashState(duration: Duration(seconds: 1));
}

class SplashState extends State<Splash> with SingleTickerProviderStateMixin {
  final Duration duration;
  AnimationController controller;
  Animation<Offset> pageSlider;

  SplashState({this.duration});

  @override
  void initState() {
    super.initState();

    controller = AnimationController(vsync: this, duration: duration);
    pageSlider = Tween<Offset>(begin: Offset(0, 1), end: Offset.zero).animate(
        CurvedAnimation(parent: controller, curve: Curves.easeOutQuint));
//    pageSlider = Tween<Offset>(begin: Offset(0, 1), end: Offset.zero).animate(CurvedAnimation(parent: controller, curve: Curves.fastOutSlowIn));
    controller.forward();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: CustomPaint(
        painter: BackgroundPainter(minPadding: 16),
        child: Stack(
          alignment: Alignment(0, 1),
          children: <Widget>[
            SlideTransition(
              position: pageSlider,
              child: buildBottomPage(context),
            ),

            buildToken(context)
          ],
        ),
      ),
    );
  }

  Widget buildBottomPage(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    return Stack(
      alignment: Alignment(0, 1),
      children: <Widget>[
        SizedBox(
          height: height/2,
          child: Container(
            child: Container(
              color: Color.fromRGBO(255, 255, 255, 0.1),
            ),

            color: Color.fromRGBO(32, 17, 27, 1.0),
          ),
        ),
/*
        Center(
          child: SizedBox(
            width: 180,
            height: 180,
            child: ClipPolygon(
              sides: 6,
              borderRadius: 5,
              child: Container(
                color: Color.fromRGBO(32, 17, 27, 1.0),
              ),
            ),
          ),
        ),
*/
      ],
    );
  }

  Widget buildToken(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      verticalDirection: VerticalDirection.up,
      children: <Widget>[
        Stack(
          alignment: Alignment(0, 0),
          children: <Widget>[
            SizedBox(
              width: 180,
              height: 180,
              child: ClipPolygon(
                sides: 6,
                borderRadius: 5,
                child: Container(
                  color: Color.fromRGBO(32, 17, 27, 1.0),
                ),
              ),
            ),

            SizedBox(
              width: 160,
              height: 160,
              child: ClipPolygon(
                sides: 6,
                borderRadius: 5,
                child: Container(
                  color: Color.fromRGBO(133, 139, 98, 1.0),
                ),
              ),
            ),

            CustomPaint(
              painter: PanPainter(),
            )
          ],
        ),

        Padding(
          padding: EdgeInsets.only(bottom: 1),
          child: Text("HERMES", style: TextStyle(
              color: Color.fromRGBO(133, 129, 98, 1.0),
              fontFamily: 'Rubik',
              fontWeight: FontWeight.bold,
              fontSize: 30
          )),
        )
      ],
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}

class BackgroundPainter extends CustomPainter {
  final int minPadding;
  BackgroundPainter({this.minPadding});

  @override
  void paint(Canvas canvas, Size size){
    final height = size.height;
    final width = size.width;
    Path background = Path();
    background.addRect(Rect.fromLTWH(0, 0, width, height));
    canvas.drawPath(background, Paint()..color = Color.fromRGBO(32, 17, 27, 1.0));


    Path cross = Path();
    Radius rad = Radius.circular(1);
    cross.addRRect(RRect.fromRectAndRadius(Rect.fromLTWH(-12.5, -1, 10, 2), rad));
    cross.addRRect(RRect.fromRectAndRadius(Rect.fromLTWH(-1, 2.5, 2, 10), rad));
    cross.addRRect(RRect.fromRectAndRadius(Rect.fromLTWH(2.5, -1, 10, 2), rad));
    cross.addRRect(RRect.fromRectAndRadius(Rect.fromLTWH(-1, -12.5, 2, 10), rad));
    
    // Calculate the number we can get with at least minPadding on each side and 50px between
    int maxC = 0, maxR = 0;
    while ((maxC+2)*25 < width-2*minPadding) maxC++;
    while ((maxR+2)*25 < height-2*minPadding) maxR++;

    double wPadding = (width - (maxC+1)*25)/2;
    double hPadding = (height - (maxR+1)*25)/2;
    for (int r=0; r<maxR; r++){
      for (int c=0; c<maxC; c++){
        canvas.save();
        canvas.translate(wPadding + 12.5 + 50*c, hPadding + 12.5 + 50*r);
        canvas.rotate(pi/4);
        canvas.drawPath(cross, Paint()..color = Color.fromRGBO(150, 140, 131, 0.25));
        canvas.restore();
      }
    }
  }

  @override
  bool shouldRepaint(CustomPainter other){
    return false;
  }
}

class PanPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size){
    Path pan = Path();
    Radius rad = Radius.circular(2.5);
    pan.addRRect(RRect.fromLTRBAndCorners(0, 0, 8, 100, bottomRight: rad, bottomLeft: rad));
    pan.addRRect(RRect.fromLTRBAndCorners(10, 0, 18, 89.08, bottomRight: rad, bottomLeft: rad));
    pan.addRRect(RRect.fromLTRBAndCorners(20, 0, 28, 79.36, bottomRight: rad, bottomLeft: rad));
    pan.addRRect(RRect.fromLTRBAndCorners(30, 0, 38, 74.91, bottomRight: rad, bottomLeft: rad));
    pan.addRRect(RRect.fromLTRBAndCorners(40, 0, 48, 66.74, bottomRight: rad, bottomLeft: rad));
    pan.addRRect(RRect.fromLTRBAndCorners(50, 0, 58, 59.45, bottomRight: rad, bottomLeft: rad));
    pan.addRRect(RRect.fromLTRBAndCorners(60, 0, 68, 52.98, bottomRight: rad, bottomLeft: rad));
    pan.addRRect(RRect.fromLTRBAndCorners(70, 0, 78, 49.98, bottomRight: rad, bottomLeft: rad));

    canvas.save();
    canvas.translate(-39, -49);
    canvas.drawPath(pan, Paint()..color = Color.fromRGBO(255, 255, 255, 1.0));
    
    Path panBar = Path();
    panBar.addRect(Rect.fromLTWH(0, 8, 78, 8));
    canvas.drawPath(panBar, Paint()..color = Color.fromRGBO(234, 234, 234, 1.0));

    Path mouthDarkener = Path();
    mouthDarkener.addRect(Rect.fromLTWH(0, 0, 78, 8));
    canvas.drawPath(mouthDarkener, Paint()..color = Color.fromRGBO(0, 0, 0, 0.1));
    canvas.restore();
  }

  @override
  bool shouldRepaint(CustomPainter other){
    return false;
  }
}