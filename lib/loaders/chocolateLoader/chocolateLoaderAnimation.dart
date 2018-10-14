import 'package:flutter/material.dart';
import 'package:bodt_chat/loaders/chocolateLoader/chocolateLoaderWidget.dart';
import 'package:bodt_chat/loaders/chocolateLoader/barPainter.dart';

class ChocolateLoaderAnimation extends AnimatedWidget {
  final ChocolateLoaderWidget widget;
  ChocolateLoaderAnimation({Key key, @required Animation<double> animation, this.widget}):
        super(key: key, listenable: animation);

  @override
  Widget build(BuildContext context){
    final Animation<double> animation = super.listenable;
    return Center(
      child: CustomPaint(
        painter: new BarPainter(widget: widget, value: animation.value),
      ),
    );
  }
}