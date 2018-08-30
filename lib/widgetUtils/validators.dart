import 'package:bodt_chat/dataUtils/user.dart';

class Validators {
  static RegExp nameExp = new RegExp(r'^[A-Za-z ]+$');
  static RegExp emailExp = new RegExp(r"[a-z0-9!#$%&'*+/=?^_`{|}~-]+(?:\.[a-z0-9!#$%&'*+/=?^_`{|}~-]+)*@(?:[a-z0-9](?:[a-z0-9-]*[a-z0-9])?\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?");
  static RegExp dobExp = new RegExp(r'^(0[1-9])|(1[0-2])/([1-9]|[12][0-9])|([3][01])/([2]([0-9])\1{3})|(19([0-9])\1{2})');
  static RegExp numberExp = new RegExp(r"\(\d{3}\) \d{3} \- \d{4}");

  static String _validate(String value, UserParameter<String> param, bool isRequired,
                          String onEmpty, String onMismatch, RegExp checker, Function save){
    value = value.trim();
    if (value.isEmpty && isRequired)
      return onEmpty;
    else if (value.isEmpty)
      return null;

    String regexMatch = checker.stringMatch(value);
    if (regexMatch == null || regexMatch.length != value.length)
      return onMismatch;

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
    return _validate(value, param, isRequired, onEmpty, onMismatch, checker ?? dobExp, save);
  }

  // validateDob has a better regex right now until MaskedTextInpurFormatter is improved
  static String validateDobMask(String value, UserParameter<String> param, bool isRequired,
      String label, String mask, String masker, RegExp maskable, Function save){
    String onEmpty = "Please enter your ${label.toLowerCase()}";
    String onMismatch = "Please enter a valid date";
    RegExp checker = RegExp(mask.replaceAll(masker, maskable.pattern));
    return _validate(value, param, isRequired, onEmpty, onMismatch, checker, save);
  }

  static String validatePhoneNumber(String value, UserParameter<String> param, bool isRequired, String label, Function save){
    String onEmpty = "Please enter your ${label.toLowerCase()}";
    String onMismatch = "Please enter a valid ${label.toLowerCase()} number";
    value = RegExp(r"[0-9]").allMatches(value).map((m) => m[0]).join();
    return _validate(value, param, isRequired, onEmpty, onMismatch, RegExp(r"\d{10}"), save);
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