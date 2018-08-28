import 'package:bodt_chat/user.dart';

class Validators {
  static RegExp nameExp = new RegExp(r'^[A-Za-z ]+$');
  static RegExp emailChecker = new RegExp(r"[a-z0-9!#$%&'*+/=?^_`{|}~-]+(?:\.[a-z0-9!#$%&'*+/=?^_`{|}~-]+)*@(?:[a-z0-9](?:[a-z0-9-]*[a-z0-9])?\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?");
  static RegExp dobExp = new RegExp(r'^(0[1-9]|1[0-2])/([1-9]|[12][0-9]|[3][01])/([2]([0-9])\1{3}|19([0-9])\1{2})');
  
  static String validateName(String value, UserParameter<String> param, Function(UserParameter<String>) save){
    value = value.trim();
    if (value.isEmpty)
      return "Please enter your name";

    if (!nameExp.hasMatch(value))
      return "Please enter only alphabetical characters";

    save(param);
    return null;
  }

  static String validateEmail(String value, UserParameter<String> param, Function(UserParameter<String>) save){
    value = value.trim();
    if (value.isEmpty)
      return "Please enter your email";

    String emailMatch = emailChecker.stringMatch(value);
    if (emailMatch == null || emailMatch.length != value.length)
      return 'Please enter a valid email';


    save(param);
    return null;
  }

  static String validateDob(String value, UserParameter<String> param, Function(UserParameter<String>) save){
    value = value.trim();
    if (value.isEmpty)
      return "Please enter your date of birth";

    String dobMatch = dobExp.stringMatch(value);
    if (dobMatch == null || dobMatch.length != value.length)
      return 'Please enter a valid date';

    save(param);
    return null;
  }
}