import 'dart:math' as math;

import 'package:flutter/material.dart';

const Color kSPLASH_SCREEN_BUTTON_COLOR = Colors.green;
const Color kSPLASH_SCREEN_LOADING_COLOR = Colors.white;

const String kMESSAGES_CHILD = "messages";
const String kTEXT_CHILD = "text";
const String kNAME_CHILD = "name";

const int kLOADING_FINISH = -1;
const double kLOADING_DIAMETER = 10.0;
const double kLOADING_PADDING = 10.0;
const double kLOADING_H_MULT = 1.0;

const double kSIGN_IN_WIDTH = 300.0;
const double kSIGN_IN_HEIGHT = 60.0;
const double kSIGN_IN_END_WIDTH =
    (kLOADING_DIAMETER + kLOADING_PADDING) * math.sqrt2 * 3;
const double kSIGN_IN_SWITCH_POINT = 0.25;

const String kDOT_REPLACEMENT = ",";

const Color kGROUPS_LIST_BACKGROUND = Colors.white;

const int kMESSAGE_GROW_ANIMATION_DURATION = 700;

const int kGROUPS_PRELOAD = 15;
