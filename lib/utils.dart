import 'package:intl/intl.dart' as intl;
import 'dart:math' as math;
import 'package:bodt_chat/constants.dart';

class Utils {
  static DateTime parseTime(String rawTime){
    if (rawTime == "0")
      return new DateTime(0);
    return DateTime.parse(rawTime.replaceAll(kDOT_REPLACEMENT, "."));
  }

  static String formatTime(String rawTime){
    if (rawTime == "0")
      return "";
    DateTime dt = parseTime(rawTime);
    var format = new intl.DateFormat("hh:mm a, EEE, MMM d, yyyy");
    return format.format(dt.toLocal());
  }

  static flippedLongCos(double radians){
//    return 1.0 - math.cos(radians/2);
    return -math.sin(radians);
  }

  // This should go from (pi, 1.0) to (2*pi, 100)
  static scaleToBig(double radians){
    // This is pretty close
    return -10.0 * (radians - math.pi) * (radians - 3.0*math.pi);
  }
}