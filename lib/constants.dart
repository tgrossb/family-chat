import 'dart:math' as math;

import 'package:flutter/material.dart';

const Color kSPLASH_SCREEN_BUTTON_COLOR = Color(0xff413c58);
const Color kSPLASH_SCREEN_LOADING_COLOR = Colors.white;

// These are all for the chocolate bar animation
class ChocolateConstants {
  static const double kCHOCOLATE_INSET = 5.0;
  static const double kCHOCOLATE_ELEVATION = 4.0;

  // Chocolate bar should have an aspect ratio of 1:1.5
  static const double kCHOCOLATE_SQUARE_WIDTH = 50.0 / 10 * 7;
  static const double kCHOCOLATE_SQUARE_HEIGHT = 75.0 / 10 * 7;

  static const int kCHOCOLATE_WIDTH_COUNT = 5;
  static const int kCHOCOLATE_HEIGHT_COUNT = 5;

  static const Color kCHOCOLATE_BASE_COLOR = Color(0xffbf8673);
  static const Color kCHOCOLATE_ELEVATED_COLOR = Color(0xffbf8672);
  static const Color kCHOCOLATE_DARK_EDGE_COLOR = Color(0xff502d27);
  static const Color kCHOCOLATE_LIGHT_EDGE_COLOR = Color(0xfff2c1ba);
  static const Color kCHOCOLATE_MIDDLE_EDGE_COLOR = Color(0xffa46b64);

  static const int kCHOCOLATE_DURATION = 1500;
}

// These are all for the dot matrix animation
class DotConstants {
  static const double kDOT_DIAMETER = 10.0;
  static const double kDOT_PADDING = 10.0;
  static const double kDOT_H_MULT = 1.0;

  static const Color kDOT_COLOR = Colors.white;

  static const int kDOT_DURATION = 1000;
  static const int kDOT_FROM_CONTAINER_DURATION = 500;
}

// These are all for the generic animated loading button
class LoadingButtonConstants {
  static const int kBUTTON_MORPH_DURATION = 500;
  static const int kBUTTON_FADE_TEXT_DURATION = 100;
  static const EdgeInsets kBUTTON_PADDING = EdgeInsets.symmetric(horizontal: 30.0, vertical: 20.0);
}

// These correspond to the firebase database id names
// Make sure that any naming changes in the database are reflected here
class DatabaseConstants {
  static const String kUSER_EXISTS_TEST = "userExistsTest";

  static const String kSUDOERS_CHILD = "sudoers";

  static const String kUSERS_CHILD = "users";
  static const String kUSERS_LIST_CHILD = "usersList";

  static const String kUSER_PUBLIC_VARS = "public";
  static const String kUSER_PRIVATE_VARS = "private";

  static const String kUSER_NAME = "name";
  static const String kUSER_EMAIL = "email";
  static const String kUSER_CELLPHONE = "cellphone";
  static const String kUSER_HOME_PHONE = "homePhone";
  static const String kUSER_DOB = "dob";

  static const String kGROUPS_CHILD = "groups";
  static const String kGROUPS_LIST_CHILD = "groupsList";

  static const String kADMINS_CHILD = "admins";
  static const String kMEMBERS_CHILD = "members";
  static const String kMESSAGES_CHILD = "messages";

  static const String kTEXT_CHILD = "text";
  static const String kNAME_CHILD = "name";
}


const int kLOADING_FINISH = -1;


//const double kSIGN_IN_WIDTH = 300.0;
//const double kSIGN_IN_HEIGHT = 60.0;
//const double kSIGN_IN_END_WIDTH =
//    (kLOADING_DIAMETER + kLOADING_PADDING) * math.sqrt2 * 3;
//const double kSIGN_IN_SWITCH_POINT = 0.25;

const int kSELECT_FIELD_SHADE = 300;

const String kDOT_REPLACEMENT = ",";

const Color kGROUPS_LIST_BACKGROUND = Colors.white;

const int kMESSAGE_GROW_ANIMATION_DURATION = 700;

const int kGROUPS_PRELOAD = 15;

const int kGROUPS_LIST_ITEM_ANIMATION_OFFSET = 100;