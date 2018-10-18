import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:bodt_chat/constants.dart';
import 'package:intl/intl.dart' as intl;

class Utils {
  static Color mixRandomColor(Color mix){
    var rand = math.Random();
    int red = ((rand.nextInt(256) + mix.red)/2).round();
    int blue = ((rand.nextInt(256) + mix.blue)/2).round();
    int green = ((rand.nextInt(256) + mix.green)/2).round();
    return Color.fromRGBO(red, green, blue, 1.0);
  }

  static String getNewGroupText(String groupName){
    // TODO: Use the proper user when global users exist
    return "Theo created the group $groupName";
  }

  static DateTime parseTime(String rawTime) {
    if (rawTime == "0") return new DateTime(0);
    return DateTime.parse(rawTime.replaceAll(kDOT_REPLACEMENT, "."));
  }

  static String formatTime(String rawTime) {
    if (rawTime == "0") return "";
    DateTime dt = parseTime(rawTime);
    return timeToFormedString(dt);
  }

  static String timeToFormedString(DateTime time){
    var format = new intl.DateFormat("hh:mm a, EEE, MMM d, yyyy");
    return format.format(time.toLocal());
  }

  static String timeToReadableString(DateTime time){
    var format = new intl.DateFormat("h:mm a, EEE, MMM d, yyyy");
    return format.format(time.toLocal());
  }

  static String timeToAbsoluteString(DateTime time){
    return time.toUtc().toIso8601String();
  }

  static String timeToKeyString(DateTime time){
    return timeToAbsoluteString(time).replaceAll(".", kDOT_REPLACEMENT);
  }

  static flippedLongCos(double radians) {
    return 1.0 - math.cos(radians / 2);
//    return -math.sin(radians);
  }

  // This should go from (pi, 1.0) to (2*pi, 100)
  static scaleToBig(double radians) {
    // This is pretty close
    return -10.0 * (radians - math.pi) * (radians - 3.0 * math.pi);
  }

  static bool textNotEmpty(String s) {
    return s != null && s.trim().length != 0;
  }
}
