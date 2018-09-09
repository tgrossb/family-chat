import 'package:flutter/material.dart';
import 'package:bodt_chat/loaders/chocolateLoader/chocolateLoaderWidget.dart';

class LoaderTest extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => LoaderTestState();
}

class LoaderTestState extends State<LoaderTest> {
  ChocolateLoaderWidget loader;

  @override
  void initState() {
    loader = new ChocolateLoaderWidget();
    loader.startLoadingAnimation();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).primaryColor,
      child: loader,
    );
  }
}