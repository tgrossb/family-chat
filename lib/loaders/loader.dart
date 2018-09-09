import 'package:flutter/material.dart';

abstract class Loader {
  // This is the shape to which a button will animate
  Container getSingleBaseContainer();

  // This is assuming it begins at getSingleBaseContainer,
  // so it should animate from there
  void startLoadingAnimation();
}