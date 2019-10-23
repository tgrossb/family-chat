import 'package:flutter/material.dart';

class Consts {
  static final Color DARK_PURPLE = Color.fromRGBO(32, 17, 27, 1.0);
  static final Color GREEN = Color.fromRGBO(133, 129, 98, 1.0);
  static final Color TEXT_GRAY = Color.fromRGBO(152, 154, 156, 1.0);
  static final Color TEXT_GRAY_5 = TEXT_GRAY.withOpacity(0.05);
  static final Color BACKGROUND_PAT = Color.fromRGBO(150, 140, 131, 1.0);
  static final Color BACKGROUND_PAT_25 = BACKGROUND_PAT.withOpacity(0.25);
  static final Color BLUE = Color.fromRGBO(66, 106, 121, 1.0);

  static final Color PAGE = Color.alphaBlend(Color.fromRGBO(255, 255, 255, 0.1), DARK_PURPLE);
  static final Color WATER_MARK = Color.alphaBlend(TEXT_GRAY_5, PAGE);
}