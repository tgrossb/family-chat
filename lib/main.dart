import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'chatScreen.dart';
import 'splash_page.dart';

final ThemeData iosTheme = new ThemeData(
  primarySwatch: Colors.orange,
  primaryColor: Colors.grey[100],
  primaryColorBrightness: Brightness.light,
);

final ThemeData defaultTheme = new ThemeData(
  primarySwatch: Colors.cyan,
  accentColor: Colors.orangeAccent[400],
  splashColor: Colors.redAccent,
  primaryTextTheme: TextTheme(display1: new TextStyle(color: Colors.black54))
);

void main() {
  runApp(new BodtChatApp());
}

class BodtChatApp extends StatelessWidget {
  static String messagesChild = "messages";
  static String text = "text";
  static String name = "name";

  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      theme: defaultTargetPlatform == TargetPlatform.iOS ? iosTheme : defaultTheme,
      home: new SplashPage(),
    );
  }
}

/*
void main() => runApp(new MyApp());

class MyApp extends StatelessWidget {
  const MyApp();

  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'Bodt App',
      home: const MyHomePage(title: 'Bodt Chat'),
    );
  }
}
*/
/*
class MyHomePage extends StatelessWidget {
  const MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(title: new Text(title)),
      body: new StreamBuilder(
          stream: Firestore.instance.collection('baby').snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) return const Text('Loading...');
            return new ListView.builder(
                itemCount: snapshot.data.documents.length,
                padding: const EdgeInsets.only(top: 10.0),
              itemExtent: 55.0,
              itemBuilder: (context, index) =>
                  _buildListItem(context, snapshot.data.documents[index]),
            );
          }),
    );
  }

  Widget _buildListItem(BuildContext context, DocumentSnapshot document) {
    return new ListTile(
      key: new ValueKey(document.documentID),
      title: new Container(
        decoration: new BoxDecoration(
          border: new Border.all(color: const Color(0x80000000)),
          borderRadius: new BorderRadius.circular(5.0),
        ),
        padding: const EdgeInsets.all(10.0),
        child: new Row(
          children: <Widget>[
            new Expanded(
              child: new Text(document['name']),
            ),
            new Text(
              document['votes'].toString(),
            ),
          ],
        ),
      ),
      onTap: () => Firestore.instance.runTransaction((transaction) async {
        DocumentSnapshot freshSnap =
        await transaction.get(document.reference);
        await transaction.update(
            freshSnap.reference, {'votes': freshSnap['votes'] + 1});
      }),
    );
  }
}*/