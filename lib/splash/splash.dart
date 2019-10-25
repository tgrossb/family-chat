import 'package:flutter/material.dart';
import 'dart:math';
import 'package:polygon_clipper/polygon_clipper.dart';
import 'package:hermes/consts.dart';
import 'package:hermes/splash/loginForm.dart';


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
    controller.forward();
  }

  @override
  Widget build(BuildContext context) {
    print(Consts.PAGE);
    print(Consts.WATER_MARK);

    return Scaffold(
      body: Stack(
        alignment: Alignment.bottomCenter,
        children: <Widget>[
          CustomPaint(
            painter: BackgroundPainter(color: Consts.BACKGROUND_PAT_25),
            child: Container(),
          ),

          CustomMultiChildLayout(
            delegate: LayoutDelegate(),
            children: <Widget>[
              LayoutId(
                  id: _LayoutParts.token,
                  child: buildToken(context)
              ),

              LayoutId(
                id: _LayoutParts.bottomPage,
                child: SlideTransition(
                  position: pageSlider,
                  child: buildBottomPage(context),
                ),
              ),
            ],
          )
        ],
      )
    );
  }

  // Constructs the bottom page layout.
  // This includes the shape of the page itself, the login form, and the watermark
  Widget buildBottomPage(BuildContext context) {
    return ClipPath(
      clipper: PageClipper(hexW: 180),
      child: Container(
          decoration: BoxDecoration(
            color: Consts.PAGE,
            image: DecorationImage(
                image: AssetImage("assets/images/brainWrapped.png"),
                fit: BoxFit.contain,
                repeat: ImageRepeat.repeatY,
                colorFilter: ColorFilter.mode(Consts.WATER_MARK, BlendMode.srcIn),
                alignment: Alignment.topCenter
            ),
          ),
          child: Stack(
            fit: StackFit.passthrough,
            children: <Widget>[
              Wrap(
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.only(left: 16, right: 16, top: 106, bottom: 16),
                    child: LoginForm(),
                  ),
                ],
              ),
            ],
          )
      ),
    );
  }

  // Constructs the token.
  // This includes the HERMES text, the hexagon, the pan flute icon, and the background
  // blocker box that encapsulates it all.
  Widget buildToken(BuildContext context){
    return Stack(
      alignment: Alignment.bottomCenter,
      children: <Widget>[
        SizedBox(
          width: 180,
          height: 220,
          child: Container(
            color: Consts.DARK_PURPLE,
          ),
        ),

        Padding(
          padding: EdgeInsets.only(bottom: 20),
          child: SizedBox(
            width: 160,
            height: 160,
            child: ClipPolygon(
              sides: 6,
              borderRadius: 5,
              child: Container(
                color: Consts.GREEN,
              ),
            ),
          ),
        ),

        Padding(
          padding: EdgeInsets.only(bottom: 100),
          child: CustomPaint(
            painter: PanPainter(),
          ),
        ),

        Padding(
          padding: EdgeInsets.only(bottom: 180),
          child: Container(
            child: Text("HERMES", style: TextStyle(
                color: Consts.GREEN,
                fontFamily: 'Rubik',
                fontWeight: FontWeight.bold,
                fontSize: 30
            )),
          ),
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

// This custom layout delegate handles the bottom page and token layout.
// It is set up to lay out the bottom page and then always place the token
// such that the middle of its hexagon is aligned with the top edge of the page.
// In other words: a godsend
class LayoutDelegate extends MultiChildLayoutDelegate {
  @override
  void performLayout(Size size){
    Size bottomPageSize = Size.zero;
    Offset bottomPagePos = Offset.zero;

    if (hasChild(_LayoutParts.bottomPage)){
      bottomPageSize = layoutChild(_LayoutParts.bottomPage, BoxConstraints.loose(size));

      bottomPagePos = size - bottomPageSize;
      positionChild(_LayoutParts.bottomPage, bottomPagePos);
    }

    if (hasChild(_LayoutParts.token)){
      Size tokenSize = layoutChild(_LayoutParts.token, BoxConstraints());
      double dx = bottomPagePos.dx + size.width/2 - tokenSize.width/2;
      double dy = bottomPagePos.dy - (tokenSize.height-100);
      positionChild(_LayoutParts.token, Offset(dx, dy));
    }
  }

  @override
  bool shouldRelayout(MultiChildLayoutDelegate oldDelegate) {
    return false;
  }
}

// This enum ensures that the ids for the bottom page and token are different
// so they can be laid out by the delegate
enum _LayoutParts {
  bottomPage,
  token
}

// Paints the background color and the cross pattern going across it.
class BackgroundPainter extends CustomPainter {
  Color color;
  BackgroundPainter({@required this.color});

  @override
  void paint(Canvas canvas, Size size){
    final height = size.height;
    final width = size.width;
    Path background = Path();
    background.addRect(Rect.fromLTWH(0, 0, width, height));
    canvas.drawPath(background, Paint()..color = Consts.DARK_PURPLE);

    Path cross = Path();
    Radius rad = Radius.circular(1);
    cross.addRRect(RRect.fromRectAndRadius(Rect.fromLTWH(-12.5, -1, 10, 2), rad));
    cross.addRRect(RRect.fromRectAndRadius(Rect.fromLTWH(-1, 2.5, 2, 10), rad));
    cross.addRRect(RRect.fromRectAndRadius(Rect.fromLTWH(2.5, -1, 10, 2), rad));
    cross.addRRect(RRect.fromRectAndRadius(Rect.fromLTWH(-1, -12.5, 2, 10), rad));

    double y = height/2+50;
    drawRow(height/2, width, 25, 50, cross, canvas);
    while (y - 12.5 < height) {
      drawRow(height-y, width, 25, 50, cross, canvas);
      drawRow(y, width, 25, 50, cross, canvas);
      y += 50;
    }
  }

  void drawRow(double y, double rowWidth, double crossWidth, double padding, Path cross, Canvas canvas){
    double x = rowWidth/2 + padding;
    drawCross(rowWidth/2, y, cross, canvas);
    while (x - crossWidth/2 < rowWidth){
      drawCross(rowWidth-x, y, cross, canvas);
      drawCross(x, y, cross, canvas);
      x += padding;
    }
  }

  // Handles all of the saving, translating, rotating, and restoring
  // Pass the center of the cross
  void drawCross(double x, double y, Path cross, Canvas canvas){
    canvas.save();
    canvas.translate(x, y);
    canvas.rotate(pi/4);
    canvas.drawPath(cross, Paint()..color = color);
    canvas.restore();
  }

  @override
  bool shouldRepaint(CustomPainter other){
    return false;
  }
}

// This builds the clip path for the bottom page.
// It is a rectangle with half of a hexagon indenting the top.
// This handles all of the math for finding those intersection points.
class PageClipper extends CustomClipper<Path> {
  double hexW;
  PageClipper({@required this.hexW});

  @override
  Path getClip(Size size){
    double r = sqrt(3.0) * (hexW/4);
    double s = sqrt((hexW*hexW)/4 - r*r);
    Offset p1 = size.topCenter(Offset.zero).translate(-r, 0);
    Offset p2 = size.topCenter(Offset.zero).translate(-r, s);
    Offset p3 = size.topCenter(Offset.zero).translate(0, hexW/2);
    Offset p4 = size.topCenter(Offset.zero).translate(r, s);
    Offset p5 = size.topCenter(Offset.zero).translate(r, 0);

    Path path = Path();
    path.addPolygon([
      size.topLeft(Offset.zero),
      p1, p2, p3, p4, p5,
      size.topRight(Offset.zero),
      size.bottomRight(Offset.zero),
      size.bottomLeft(Offset.zero)
    ], true);

    return path;
  }

  @override
  bool shouldReclip(CustomClipper oldDelegate) {
    return false;
  }
}

// This paints the pan flute icon.
// This will probably be replaced with just an icon image once the icon changes
// to a lyre, as it will probably be too complicated to draw easily with canvas methods.
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