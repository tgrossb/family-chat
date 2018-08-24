import 'dart:io';
import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CountrySelector extends StatefulWidget {
  static Map<String, String> codeToPhone, nameToCode;
  static List<Country> countries;

  final Function(String) saveCountry;
  CountrySelector({@required this.saveCountry});

  @override
  State<StatefulWidget> createState() => new CountrySelectorState(saveCountry: saveCountry);

  // Its a good idea to call this somewhere before this will be needed, although it shouldn't take too long
  static Future<void> preloadCountries([BuildContext context, bool force = false]) async {
    if (countries != null && countries.length > 0 && !force)
      return;

    String codeToPhoneString = await DefaultAssetBundle.of(context).loadString("assets/codeToPhone.json");
    String nameToCodeString = await DefaultAssetBundle.of(context).loadString("assets/nameToCode.json");

    Map ctp = json.decode(codeToPhoneString);
    codeToPhone = ctp.map((dynamic key, dynamic value) => MapEntry(key.toString(), value.toString()));

    Map ntc = json.decode(nameToCodeString);
    nameToCode = ntc.map((dynamic key, dynamic value) => MapEntry(key.toString(), value.toString()));

    countries = [];
    for (String name in nameToCode.keys){
      String isoCode = nameToCode[name];
      countries.add(new Country(name: name, isoCode: isoCode, phoneCode: codeToPhone[isoCode]));
    }
  }
}

class CountrySelectorState extends State<CountrySelector> {
  Function(String) saveCountry;

  CountrySelectorState({@required this.saveCountry}){
    if (CountrySelector.countries == null || CountrySelector.countries.length == 0)
      CountrySelector.preloadCountries(context);
  }

  @override
  Widget build(BuildContext context){
    return DropdownButton<String>(
      items: CountrySelector.countries.map((Country country) =>
        DropdownMenuItem<String>(
          value: country.name,
          child: new Row(
            children: <Widget>[
//              country.flag,
              Text(country.name)
            ],
          ),
        )
      ).toList(),
      onChanged: saveCountry,
    );
  }
}

class Country {
  String name, isoCode, phoneCode;
  Image flag;

  Country({this.name, this.isoCode, this.phoneCode}):
      flag = Image.asset('assets/flags/borderless_16x10/00_cctld/${isoCode.toLowerCase()}.png');
}