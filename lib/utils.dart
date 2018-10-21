import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:bodt_chat/constants.dart';
import 'package:intl/intl.dart' as intl;

class Utils {
  static dynamic stripParent(Map m){
    assert(m.keys.length == 1);
    return m[getRoot(m)];
  }

  static dynamic getRoot(Map m){
    assert(m.keys.length == 1);
    return m.keys.toList()[0];
  }

  static Color pickTextColor(Color background){
    // Uses perspective luminance (the human eye favors green)
    double luminance = (0.299 * background.red + 0.587 * background.green + 0.144 * background.blue) / 255;
    if (luminance < 0.5)
      return Colors.black;
    return Colors.white;
  }

  static Color stringToColor(String hexString, int defaultValue){
    int parsedValue = defaultValue;
    try {
      parsedValue = int.parse(hexString, radix: 16);
    } catch (e){
      print("Letting parseColor fail silently");
    }

    return Color(parsedValue);
  }

  static String colorToString(Color color){
    return color.value.toRadixString(16);
  }

  static Color mixRandomColor(Color mix){
    var rand = math.Random();
    int red = ((rand.nextInt(256) + mix.red)/2).round();
    int blue = ((rand.nextInt(256) + mix.blue)/2).round();
    int green = ((rand.nextInt(256) + mix.green)/2).round();
    return Color.fromRGBO(red, green, blue, 1.0);
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

  static String timeToReadableString(DateTime time, {bool short = true}){
    DateTime now = DateTime.now();
    DateTime lastLocalTime = time.toLocal();
    Duration diff = now.difference(lastLocalTime).abs();

    // Use now if the difference is less than a minute
    if (diff < Duration(minutes: 1))
      return "Now";

    // Use the minutes since if the difference is less than an hour
    if (diff < Duration(hours: 1))
      return "${diff.inMinutes} min";


    // Use the clock time if the time is still today
    // TODO: Short?
    DateTime midnight = DateTime(now.year, now.month, now.day);
    if (lastLocalTime.isAfter(midnight))
      return intl.DateFormat(preferredTimeFormat()).format(lastLocalTime);

    // Use the day of the week if the time is within the past six days
    // Include the time if it is not short
    DateTime sixDaysAgo = now.subtract(Duration(days: 6));
    if (lastLocalTime.isAfter(sixDaysAgo))
      return intl.DateFormat(short ? "EEE" : preferredTimeFormat("EEE ")).format(lastLocalTime);

    // Use the month and day of month if the last message occurred within this year
    // Include the time if it is not short
    DateTime jan1 = DateTime(now.year);
    if (lastLocalTime.isAfter(jan1))
      return intl.DateFormat(short ? "MMM d" : preferredTimeFormat("MMM d, ")).format(lastLocalTime);

    // Default is to just use the full month day year
    // Include the time if it is not short
    // Use the correct order based on the constants
    String formatter = kDAY_MONTH_YEAR_ORDER.join("/")
                        ..replaceAll("m", kPREFERRED_MONTH_NUM)
                        ..replaceAll("d", kPREFERRED_DAY_NUM)
                        ..replaceAll("y", kPREFERRED_YEAR);
    return intl.DateFormat(short ? formatter : preferredTimeFormat(formatter + " ")).format(lastLocalTime);
  }

  static String preferredTimeFormat([String prefix = ""]){
    String form = "$prefix$kPREFERRED_HOUR:mm";
    if (kPREFERRED_USE_SECONDS)
      form += ":ss";

    if (kPREFERRED_HOUR.substring(0, 1) == "h")
      form += " a";
    return form;
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
