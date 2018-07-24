import 'package:flutter/material.dart';

class SlideLeftRoute extends PageRouteBuilder {
  final Widget widget;
  SlideLeftRoute({this.widget}):
  super(
    pageBuilder: (BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation) => widget,
    transitionsBuilder: (BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation, Widget child) =>
      new SlideTransition(
        position: new Tween<Offset>(
          begin: const Offset(1.0, 0.0),
          end: const Offset(0.0, 0.0),
        ).animate(animation),

        child: child/*SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0.0, -1.0),
            end: const Offset(0.0, 0.0),
          ).animate(new CurvedAnimation(parent: animation, curve: Interval(0.0, 1.0, curve: Curves.linear))),

          child: child,
        ),*/
      ),
    );
}

/*
          new SlideTransition(
      position: new Tween<Offset>(
        begin: const Offset(1.0, 0.0),
        end: Offset.zero,
      ).animate(animation),
      child: new ScaleTransition(
        scale: new Tween<double>(
          begin: 1.0,
          end: 0.0
        ).animate(animation),
        child: child
      ),
    )
  );
 */