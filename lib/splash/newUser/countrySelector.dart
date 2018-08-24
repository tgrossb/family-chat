import 'dart:io';
import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:bodt_chat/searchablePopupMenu/searchablePopupMenuButton.dart';

class CountrySelector extends StatefulWidget {
  static Map<String, String> codeToPhone, nameToCode;
  static List<Country> countries;
  static Map<String, Country> nameToCountry;

  final Function(String) saveCountry;
  CountrySelector({@required this.saveCountry});

  @override
  State<StatefulWidget> createState() => new CountrySelectorState(saveCountry: saveCountry);

  // Its a good idea to call this somewhere before this will be needed, although it shouldn't take too long
  static Future<void> preloadCountries([BuildContext context, bool force = false]) async {
    if (countries != null && countries.length > 0 && !force)
      return;

    String codeToPhoneString = await DefaultAssetBundle.of(context).loadString("assets/jsons/codeToPhone.json");
    String nameToCodeString = await DefaultAssetBundle.of(context).loadString("assets/jsons/shortenedNameToCode.json");

    Map ctp = json.decode(codeToPhoneString);
    codeToPhone = ctp.map((dynamic key, dynamic value) => MapEntry(key.toString(), value.toString()));

    Map ntc = json.decode(nameToCodeString);
    nameToCode = ntc.map((dynamic key, dynamic value) => MapEntry(key.toString(), value.toString()));

    countries = [];
    nameToCountry = {};
    for (String name in nameToCode.keys){
      String isoCode = nameToCode[name];
      Country country = new Country(name: name, isoCode: isoCode, phoneCode: codeToPhone[isoCode]);
      countries.add(country);
      nameToCountry[name] = country;
    }
  }
}

class CountrySelectorState extends State<CountrySelector> {
  Function(String) saveCountry;
  Country selectedCountry;

  CountrySelectorState({@required this.saveCountry}){
    if (CountrySelector.countries == null || CountrySelector.countries.length == 0)
      CountrySelector.preloadCountries(context);
    selectedCountry = CountrySelector.nameToCountry["United States"];
  }

  PopupMenuItem<Country> buildOption(Country country){
    return PopupMenuItem<Country>(
      value: country,
      child: Row(
        children: <Widget>[
          country.flag,
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 8.0),
            child: Text(country.name + " (+" + country.phoneCode + ")"),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context){
    return SearchablePopupMenuButton<Country>(
      onSelected: (Country result){
        setState(() {
          selectedCountry = result;
        });
        saveCountry(result.phoneCode);
      },
      itemBuilder: (BuildContext context) => CountrySelector.countries.map(buildOption).toList(),
      child: Row(
        children: <Widget>[
          selectedCountry.flag,
          Padding(
            padding: EdgeInsets.only(left: 8.0),
            child: Text("+" + selectedCountry.phoneCode),
          )
        ],
      ),
      initialValue: selectedCountry,
    );
/*
    return AlternateDropdownButton<Country>(
      value: selectedCountry,
      items: CountrySelector.countries.map((Country country) =>
        AlternateDropdownMenuItem<Country>(
          value: country,
          child: new Row(
            children: <Widget>[
              country.flag,
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 8.0),
                child: Text(country.name + " (+" + country.phoneCode.toString() + ")", overflow: TextOverflow.ellipsis)
              )
            ],
          ),
        )
      ).toList(),
      selectedItems: CountrySelector.countries.map((Country country) =>
        AlternateDropdownMenuItem<Country>(
          value: country,
          child: new Row(
            children: <Widget>[
              country.flag,
              Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8.0),
                  child: Text("+" + country.phoneCode.toString())
              )
            ],
          ),
        )
      ).toList(),
      onChanged: (Country newCountry){
        setState(() {
          selectedCountry = newCountry;//CountrySelector.nameToCountry[newCountry];
        });
        saveCountry(newCountry.phoneCode);
      },
    );
*/
  }
}

class Country {
  String name, isoCode, phoneCode;
  Image flag;

  Country({this.name, this.isoCode, this.phoneCode}):
      flag = Image.asset('assets/flags/borderless_16x10/00_cctld/${isoCode.toLowerCase()}.png');
}