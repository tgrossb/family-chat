import 'package:flutter/material.dart';
import 'package:bodt_chat/dataUtils/dataBundles.dart';
import 'package:bodt_chat/dataUtils/countryList.dart';

class CountryPickerDialog extends StatefulWidget {
  @override
  State createState() => new CountryPickerDialogState();
}

class CountryPickerDialogState extends State<CountryPickerDialog> {
  Widget buildSearch(BuildContext context){
    return TextField(
      decoration: InputDecoration(
        prefixIcon: Icon(Icons.search),
        hintText: "Search",
        border: InputBorder.none
      ),
    );
  }

  Widget buildList(BuildContext context){
    ThemeData theme = Theme.of(context);
    return ListView.builder(
      shrinkWrap: true,
      itemCount: CountryList.countries.length,
      itemBuilder: (context, index) {
        CountryData country = CountryList.countries[index];
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
}