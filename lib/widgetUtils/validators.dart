import 'package:bodt_chat/dataUtils/user.dart';

class Validators {

  static RegExp nameExp = new RegExp(r'^[A-Za-z]+ [A-Za-z]+$');
  static RegExp emailExp = new RegExp(r"[a-z0-9!#$%&'*+/=?^_`{|}~-]+(?:\.[a-z0-9!#$%&'*+/=?^_`{|}~-]+)*@(?:[a-z0-9](?:[a-z0-9-]*[a-z0-9])?\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?");
  static RegExp numberExp = new RegExp(r"\(\d{3}\) \d{3} \- \d{4}");

  static String _validate(String value, UserParameter<String> param, bool isRequired,
                          String onEmpty, String onMismatch, RegExp checker, Function save){
    value = value.trim();
    if (value.isEmpty && isRequired)
      return onEmpty;
    else if (value.isEmpty)
      return null;

    String regexMatch = checker.stringMatch(value);
    if (regexMatch == null || regexMatch.length != value.length) {
      print("Mismatch error on $value");
      return onMismatch;
    }

    save(param);
    return null;
  }

  static String validateName([String value, UserParameter<String> param, bool isRequired, String label, Function save, RegExp checker]){
    String onEmpty = "Please enter your ${label.toLowerCase()}";
    String onMismatch = "Please enter only alphabetical characters";
    return _validate(value, param, isRequired, onEmpty, onMismatch, checker ?? nameExp, save);
  }

  static String validateEmail([String value, UserParameter<String> param, bool isRequired, String label, Function save, RegExp checker]){
    String onEmpty = "Please enter your ${label.toLowerCase()}";
    String onMismatch = "Please enter a valid email address";
    return _validate(value, param, isRequired, onEmpty, onMismatch, checker ?? emailExp, save);
  }

  static String validateDob([String value, UserParameter<String> param, bool isRequired, String label, Function save, RegExp checker]){
    String onEmpty = "Please enter your ${label.toLowerCase()}";
    String onMismatch = "Please enter a valid date";

    value = value.trim();
    if (value.isEmpty && isRequired)
      return onEmpty;
    else if (value.isEmpty)
      return null;

    String nums = RegExp(r"[0-9]").allMatches(value).map((m) => m[0]).join();
    if (nums.length < 8)
      return onMismatch;

    int month = int.parse(nums.substring(0, 2));
    int day = int.parse(nums.substring(2, 4));
    int year = int.parse(nums.substring(4));

    if (month < 1 || month > 12)
      return "There is no " + ordinalize(month) + " month, idiot";

    if (day < 1 || day > getDayCount(month, year))
      return "There is no " + ordinalize(day) + " day in the " + ordinalize(month) + " month, idiot";

    DateTime now = DateTime.now();
    DateTime date = new DateTime(year, month, day);

    if (now.isBefore(date))
      return "Really, you're born in the future? Get. Out.";

    int age = (now.difference(date).inDays/365).floor();
    if (age > 100)
      return "Really, you're $age years old? Leave.";

    return null;
  }

  static int getDayCount(int month, int year){
    return DateTime.utc(year, month+1, 1).difference(DateTime.utc(year, month, 1)).inDays;
  }

  static String ordinalize(int c){
    String suffix = "th";
    int digit = c % 10;
    if ((digit > 0 && digit < 4) && (c < 11 || c > 13)) {
      suffix = ["st", "nd", "rd"][digit - 1];
    }
    return "$c$suffix";
  }

  static String validatePhoneNumber(String value, UserParameter<String> param, bool isRequired, String label, Function save){
    String onEmpty = "Please enter your ${label.toLowerCase()}";
    String onMismatch = "Please enter a valid ${label.toLowerCase()} number";
    value = RegExp(r"[0-9]").allMatches(value).map((m) => m[0]).join();
    return _validate(value, param, isRequired, onEmpty, onMismatch, RegExp(r"\d{11,13}"), save);
  }

  // This doesn't work yet
  static String validatePhoneNumberMask(String value, UserParameter<String> param, bool isRequired,
      String label, String mask, String masker, RegExp maskable, Function save){
    String onEmpty = "Please enter your ${label.toLowerCase()}";
    String onMismatch = "Please enter a valid ${label.toLowerCase()} number";
    RegExp checker = RegExp(mask.replaceAll(masker, maskable.pattern));
    return _validate(value, param, isRequired, onEmpty, onMismatch, checker, save);
  }
}