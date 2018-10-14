import 'package:flutter/material.dart';
import 'package:bodt_chat/dataUtils/dataBundles.dart';
import 'package:bodt_chat/dataUtils/countryList.dart';

class CountryPickerDialog extends StatefulWidget {
  @override
  State createState() => new CountryPickerDialogState();
}

class CountryPickerDialogState extends State<CountryPickerDialog> {
  TextEditingController searchController = TextEditingController();
  String previousSearch = "";
  List<CountryData> itemList = CountryList.countries.sublist(0, CountryList.countries.length);

  bool checkCountrySearchTerm([String term, CountryData country, bool isLowered = true]){
    if (!isLowered)
      term = term.toLowerCase();
    return country.name.toLowerCase().contains(term) || country.phoneCode.contains(term);
  }

  void search(String term){
    term = term.toLowerCase();
    setState((){
      // If this is an empty string, use the full country list
      if (term.length == 0)
        itemList = CountryList.countries.sublist(0, CountryList.countries.length);
      // If this is the continuation of a previous search, then filter the item list
      else if (term.substring(0, term.length-1) == previousSearch)
        itemList.retainWhere((country) => checkCountrySearchTerm(term, country));
      // If not, filter the full country list
      else {
        itemList.removeWhere((country) => true);
        for (CountryData country in CountryList.countries)
          if (checkCountrySearchTerm(term, country))
            itemList.add(country);
      }

      // Make sure to save the previous search term
      previousSearch = term;
    });
  }

  Widget buildSearch(BuildContext context){
    return Column(
      children: <Widget>[
        TextField(
          controller: searchController,
          autofocus: true,
          onChanged: search,
          style: Theme.of(context).accentTextTheme.subhead,
          decoration: InputDecoration(
              prefixIcon: Container(
                padding: EdgeInsets.only(right: 10.0),
                child: Icon(Icons.search),
              ),
              suffixIcon: searchController.text.length > 0 ?
                InkWell(
                  child: Icon(Icons.clear),
                  onTap: () {
                      setState(() {
                        searchController.clear();
                      });

                      search("");
                    },
                ) : null,
              hintText: "Search",
              border: InputBorder.none,
              hintStyle: Theme.of(context).accentTextTheme.subhead.copyWith(color: Colors.black26),
              filled: false,
          ),
        ),

        Divider(
          height: 0.0,
        )
      ],
    );
  }

  Widget buildList(BuildContext context){
    ThemeData theme = Theme.of(context);

    // If the item list length is zero, display a "no countries found message"
    if (itemList.length == 0)
      return Container(
        padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
        child: RichText(
          textAlign: TextAlign.center,
          text: TextSpan(
            style: theme.accentTextTheme.subhead.copyWith(fontWeight: FontWeight.bold),
            children: <TextSpan>[
              new TextSpan(text: "No countries found matching the search term \""),
              new TextSpan(text: searchController.text, style: theme.accentTextTheme.subhead),
              new TextSpan(text: "\"")
            ]
          ),
        )
      );

    return ListView.builder(
      shrinkWrap: true,
      itemCount: itemList.length,
      itemBuilder: (context, index) {
        CountryData country = itemList[index];
        return GestureDetector(
          onTap: () => Navigator.pop(context, country),
          child: ListTile(
            leading: Container(
              height: theme.iconTheme.size ?? 24.0,   // Set the image to be the height of an icon
              child: country.flag,
            ),
            title: Text(country.name, style: theme.accentTextTheme.body1),
            subtitle: Text(country.phoneCode, style: theme.accentTextTheme.body2.copyWith(color: Colors.black26)),
          ),
        );
      },
    );
  }

  Widget build(BuildContext context) {
    return SimpleDialog(
      contentPadding: EdgeInsets.only(top: 0.0, bottom: 16.0),
      children: <Widget>[
        buildSearch(context),
        Container(
          width: 400.0,
          height: 500.0,
          child: buildList(context),
        )
      ],
    );
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }
}