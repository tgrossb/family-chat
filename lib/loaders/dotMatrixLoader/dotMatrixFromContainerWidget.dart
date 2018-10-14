import 'package:flutter/material.dart';
import 'package:flutter/animation.dart';
import 'dart:math' as math;
import 'package:bodt_chat/loaders/dotMatrixLoader/dotMatrixLoaderWidget.dart';

class DotMatrixFromContainerWidget extends StatefulWidget {
  final DotMatrixLoaderWidget loaderWidget;
  final Function finishedCallback;

  DotMatrixFromContainerWidget({GlobalKey key, @required this.loaderWidget, @required this.finishedCallback}) :
        super(key: key ?? GlobalKey());

  @override
  State<StatefulWidget> createState() => DotMatrixFromContainerWidgetState(loaderWidget: loaderWidget);

  void startAnimation() async {
    ((super.key as GlobalKey).currentState as DotMatrixFromContainerWidgetState).controller.forward();
  }
}

class DotMatrixFromContainerWidgetState extends State<DotMatrixFromContainerWidget> with SingleTickerProviderStateMixin {
  AnimationController controller;
  Animation<double> dotBorderRadius, dotDiameter;
  DotMatrixLoaderWidget loaderWidget;

  DotMatrixFromContainerWidgetState({@required this.loaderWidget});

  @override
  void initState(){
    controller = AnimationController(vsync: this, duration: loaderWidget.fromContainerDuration);

    dotBorderRadius = new Tween(begin: 0.0, end: loaderWidget.diameter/2).animate(
        CurvedAnimation(parent: controller, curve: Curves.linear));

    dotDiameter = new Tween(begin: (loaderWidget.diameter*3 + loaderWidget.padding*4)/3, end: loaderWidget.diameter).animate(
      CurvedAnimation(parent: controller, curve: Curves.linear));

    // Add the finished callback to the controller
    controller.addStatusListener((status){
      if (status == AnimationStatus.completed) {
        widget.finishedCallback();
      }
    });

    super.initState();
  }

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
              color: loaderWidget.color,
              borderRadius: BorderRadius.only(topLeft: tl, bottomLeft: bl, topRight: tr, bottomRight: br)
          ),
        )
    );
  }

  Widget buildRow([BuildContext context, double roundTop = -1.0, double roundBottom = -1.0]){
    double diam = dotDiameter.value;
    double pad = math.max(loaderWidget.diameter + loaderWidget.padding - diam, 0.0);

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
        buildRow(context, loaderWidget.diameter/2),
        buildRow(context),
        buildRow(context, -1.0, loaderWidget.diameter/2),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      builder: (context, child) => buildToDotsAnimation(context),
      animation: controller,
    );
  }

  @override
  void dispose() {
    controller.dispose();

    super.dispose();
  }
}