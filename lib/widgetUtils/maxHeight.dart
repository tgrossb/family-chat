import 'package:flutter/material.dart';

class MaxHeight extends StatelessWidget {
  final List<Widget> children;
  final MainAxisAlignment mainAxisAlignment;

  MaxHeight({@required this.children, this.mainAxisAlignment = MainAxisAlignment.start});

  Widget build(BuildContext context){
    return IntrinsicHeight(
      child: Row(
        mainAxisAlignment: mainAxisAlignment,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: children,
      ),
    );
  }
}