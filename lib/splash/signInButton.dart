import 'package:flutter/material.dart';
import 'package:flutter/animation.dart';
import 'dart:math' as math;
import 'package:bodt_chat/constants.dart';

class SignInButton extends StatelessWidget {
  final Function startAnimation;
  final Animation<double> controller;
  final Animation<double> shrinkWidth, expandHeight, buttonBorderRadius;
  final Animation<double> dotBorderRadius, dotDiameter;
  final Animation<Color> dotColorAnimation;

  SignInButton({Key key, this.controller, this.startAnimation,}):
    shrinkWidth = new Tween(begin: kSIGN_IN_WIDTH, end: kSIGN_IN_END_WIDTH).animate(
      CurvedAnimation(parent: controller, curve: new Interval(0.0, kSIGN_IN_SWITCH_POINT))),

    expandHeight = new Tween(begin: kSIGN_IN_HEIGHT, end: kSIGN_IN_END_WIDTH).animate(
      CurvedAnimation(parent: controller, curve: new Interval(0.0, kSIGN_IN_SWITCH_POINT))),

    buttonBorderRadius = new Tween(begin: kSIGN_IN_HEIGHT/2, end: kLOADING_DIAMETER/2).animate(
      CurvedAnimation(parent: controller, curve: new Interval(0.0, 2*kSIGN_IN_SWITCH_POINT))),

    dotColorAnimation = new ColorTween(begin: kSPLASH_SCREEN_BUTTON_COLOR, end: kSPLASH_SCREEN_LOADING_COLOR).animate(
      CurvedAnimation(parent: controller, curve: new Interval(kSIGN_IN_SWITCH_POINT, 1.0))),

    dotBorderRadius = new Tween(begin: 0.0, end: kLOADING_DIAMETER/2).animate(
      CurvedAnimation(parent: controller, curve: Interval(kSIGN_IN_SWITCH_POINT, 1.0))),

    dotDiameter = new Tween(begin: kSIGN_IN_END_WIDTH/3, end: kLOADING_DIAMETER).animate(
      CurvedAnimation(parent: controller, curve: Interval(kSIGN_IN_SWITCH_POINT, 1.0))),
    super(key: key);

  Widget buildCircle(BuildContext context, double diameter, double p, Map<String, double> radii){
    Radius defaultRad = Radius.circular(dotBorderRadius.value);
    Radius tl = radii.containsKey("tl") ? Radius.circular(radii["tl"]) : defaultRad;
    Radius bl = radii.containsKey("bl") ? Radius.circular(radii["bl"]) : defaultRad;
    Radius tr = radii.containsKey("tr") ? Radius.circular(radii["tr"]) : defaultRad;
    Radius br = radii.containsKey("br") ? Radius.circular(radii["br"]) : defaultRad;
    return Padding(
      padding: EdgeInsets.all(p),

      child: Container(
        width: diameter,
        height: diameter,
        decoration: BoxDecoration(
          color: dotColorAnimation.value,
          borderRadius: BorderRadius.only(topLeft: tl, bottomLeft: bl, topRight: tr, bottomRight: br)
        ),
      )
    );
  }

  Widget buildRow([BuildContext context, double roundTop = -1.0, double roundBottom = -1.0]){
    double diam = dotDiameter.value;
    double pad = math.max(kLOADING_DIAMETER + kLOADING_PADDING - diam, 0.0);

    return new Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        buildCircle(context, diam, pad, roundTop >= 0.0 ? {"tl": roundTop} : (roundBottom >= 0.0 ? {"bl": roundBottom} : {})),
        buildCircle(context, diam, pad, {}),
        buildCircle(context, diam, pad, roundTop >= 0.0 ? {"tr": roundTop} : (roundBottom >= 0.0 ? {"br": roundBottom} : {})),
      ],
    );
  }

  Widget buildToDotsAnimation(BuildContext context){
    return new Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        buildRow(context, kLOADING_DIAMETER/2),
        buildRow(context),
        buildRow(context, -1.0, kLOADING_DIAMETER/2),
      ],
    );
  }

  Widget buildAnimation(BuildContext context, Widget child){
    // Button Animation accounts for width and height animations
    if (expandHeight.value < kSIGN_IN_END_WIDTH)
      return buildButtonAnimation(context);
    else
      return buildToDotsAnimation(context);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      builder: buildAnimation,
      animation: controller,
    );
  }

  Widget buildButtonAnimation(BuildContext context){
    return new GestureDetector(
      onTap: () => shrinkWidth.value == kSIGN_IN_WIDTH ? startAnimation() : (){},
      child: new Container(
        width: shrinkWidth.value,
        height: expandHeight.value,
        child: shrinkWidth.value > 200 ?
          new Text("Sign in with Google", style: Theme.of(context).primaryTextTheme.title.copyWith(color: kSPLASH_SCREEN_LOADING_COLOR)) : null,
        alignment: FractionalOffset.center,
        decoration: new BoxDecoration(
            color: kSPLASH_SCREEN_BUTTON_COLOR,
            borderRadius: new BorderRadius.all(Radius.circular(buttonBorderRadius.value))
        ),
      ),
    );
  }
}