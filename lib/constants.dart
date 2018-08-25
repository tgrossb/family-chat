import 'dart:math' as math;

import 'package:flutter/material.dart';

const Color kSPLASH_SCREEN_BUTTON_COLOR = Color(0xff413c58);
const Color kSPLASH_SCREEN_LOADING_COLOR = Colors.white;

const String kUSER_EXISTS_TEST = "userExistsTest";

const String kSUDOERS_CHILD = "sudoers";

const String kUSERS_CHILD = "users";
const String kUSERS_LIST_CHILD = "usersList";

const String kUSER_PUBLIC_VARS = "public";
const String kUSER_PRIVATE_VARS = "private";

const String kUSER_NAME = "name";
const String kUSER_EMAIL = "email";
const String kUSER_CELLPHONE = "cellphone";

const String kGROUPS_CHILD = "groups";
const String kGROUPS_LIST_CHILD = "groupsList";

const String kADMINS_CHILD = "admins";
const String kMEMBERS_CHILD = "members";
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

const int kSELECT_FIELD_SHADE = 300;

const String kDOT_REPLACEMENT = ",";

const Color kGROUPS_LIST_BACKGROUND = Colors.white;

const int kMESSAGE_GROW_ANIMATION_DURATION = 700;

const int kGROUPS_PRELOAD = 15;

const int kGROUPS_LIST_ITEM_ANIMATION_OFFSET = 100;