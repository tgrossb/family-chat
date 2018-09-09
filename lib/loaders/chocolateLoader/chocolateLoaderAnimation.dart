import 'package:flutter/material.dart';
import 'package:bodt_chat/loaders/chocolateLoader/chocolateLoaderWidget.dart';
import 'package:bodt_chat/loaders/chocolateLoader/squarePainter.dart';
import 'package:bodt_chat/constants.dart';

class ChocolateLoaderAnimation extends AnimatedWidget {
  final ChocolateLoaderWidget widget;
  ChocolateLoaderAnimation({Key key, @required Animation<double> animation, this.widget}):
        super(key: key, listenable: animation);

  @override
  Widget build(BuildContext context){
    final Animation<double> animation = super.listenable;
    if (animation.value < 0.25)
      return buildBar(context, widget.widthCount, widget.heightCount);
    else if (animation.value < 0.5)
      return buildBarWithCut(context, widget.widthCount, widget.heightCount, 1.5, 3.5);
    return buildBar(context, widget.widthCount, widget.heightCount);
  }

  Column buildBarWithCut(BuildContext context, int width, int height, double cutStart, double cutEnd){
    List<Widget> bottomRows = new List(cutStart.floor());
    for (int c=0; c<bottomRows.length; c++)
      bottomRows[c] = buildRow(context, width);

    List<Widget> topRows = new List(height - cutEnd.ceil());
    for (int c=0; c<topRows.length; c++)
      topRows[c] = buildRow(context, width);

    List<Widget> middleRows = new List(height - bottomRows.length - topRows.length);
    for (int c=0; c<middleRows.length; c++)
      middleRows[c] = buildCutRow(context, width, cutStart - cutEnd, c);
  }

  Row buildCutRow(BuildContext context, int width, double cutHeight, int row){
    
  }

  Column buildBar(BuildContext context, int width, int height){
    List<Widget> rows = new List(height);
    for (int c=0; c<rows.length; c++)
      rows[c] = buildRow(context, width);

    return Column(children: rows);
  }

  Row buildRow(BuildContext context, int width){
    List<Widget> squares = new List(width);
    for (int c=0; c<squares.length; c++)
      squares[c] = CustomPaint(
        size: Size(widget.squareWidth, widget.squareHeight),
        painter: new SquarePainter(widget: widget)
      );

    return Row(children: squares);
  }
}