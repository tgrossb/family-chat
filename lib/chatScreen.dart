import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'chatMessage.dart';
import 'main.dart';

class ChatScreen extends StatefulWidget {
  ChatScreen({this.user, this.chatName});
  final FirebaseUser user;
  final String chatName;

  @override
  State createState() => new ChatScreenState(user, chatName);
}

class ChatScreenState extends State<ChatScreen> with TickerProviderStateMixin {
  static String dotReplace = ",";

  FirebaseUser user;
  String chatName;
  DatabaseReference mainRef;
  StreamSubscription<Event> mainRefSubscription;

  final int growAnimationDuration = 700;
  final List<ChatMessage> _messageSaves = [];
  final TextEditingController _textController = new TextEditingController();
  bool _isWriting = false;

  ChatScreenState(FirebaseUser user, String chatName){
    this.user = user;
    this.chatName = chatName;
    FirebaseDatabase db = FirebaseDatabase.instance;
    db.setPersistenceEnabled(true);

    mainRef = db.reference().child(chatName).child(BodtChatApp.messagesChild);
    mainRef.keepSynced(true);
    mainRefSubscription = mainRef.onChildAdded.listen(_onMessageAdded);
  }

  void _onMessageAdded(Event event){
    setState(() {
      ChatMessage message = new ChatMessage(
        text: event.snapshot.value['text'],
        name: event.snapshot.value['name'],
        myName: user.displayName,
        animationController: new AnimationController(
          duration: new Duration(milliseconds: growAnimationDuration),
          vsync: this
        ),
      );
      // Insert to the front
      _messageSaves.insert(0, message);
      message.animationController.forward();
    });
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        appBar: new AppBar(
          title: new Text(chatName),
          // No elevation if its on ios
          elevation: Theme.of(context).platform == TargetPlatform.iOS ? 0.0 : 4.0,
        ),
        body: new Container(
            child: new Column(
              children: <Widget>[
                 new Flexible(
                   child: new ListView.builder(
                     padding: new EdgeInsets.all(8.0),
                     reverse: true,
                     itemBuilder: (_, int index) => _messageSaves[index],
                     itemCount: _messageSaves.length,
                   ),
                 ),

                new Divider(height: 1.0),

                new Container(
                  decoration: new BoxDecoration(color: Theme.of(context).cardColor),
                  child: _buildTextComposer(),
                ),

              ],
            ),

            decoration: Theme.of(context).platform == TargetPlatform.iOS ?
            new BoxDecoration(border: new Border(top: new BorderSide(color: Colors.grey[200]))) : null
        )
    );
  }

  Widget _buildTextComposer() {
    return new IconTheme(
      data: new IconThemeData(color: Theme.of(context).accentColor),
      child: new Container(
        margin: const EdgeInsets.symmetric(horizontal: 8.0),
        child: new Row(
          children: <Widget>[

            new Flexible(
              child: new TextField(
                controller: _textController,
                onChanged: (String text) {
                  setState(() {
                    _isWriting = text.length > 0;
                  });
                },
                onSubmitted: _handleSubmitted,
                decoration: new InputDecoration.collapsed(hintText: "Send a message"),
              ),
            ),

            new Container(
              margin: new EdgeInsets.symmetric(horizontal: 4.0),
              child: Theme.of(context).platform == TargetPlatform.iOS ?
              new CupertinoButton(
                child: new Text("Send"),
                onPressed: _isWriting ? () => _handleSubmitted(_textController.text) : null,
              )

                  : new IconButton(
                icon: new Icon(Icons.send),
                onPressed: _isWriting ? () => _handleSubmitted(_textController.text) : null,
              ),

            ),

          ],
        ),
      ),
    );
  }

  void _handleSubmitted(String text) {
    _textController.clear();
    setState(() {
      _isWriting = false;
    });

    String name = user.displayName;
    ChatMessage message = new ChatMessage(
      text: text,
      name: name, myName: name,
      animationController: new AnimationController(
        duration: new Duration(milliseconds: growAnimationDuration),
        vsync: this,
      ),
    );

    // Stamp it with absolute time so it sorts properly
    mainRef.child(new DateTime.now().toUtc().toIso8601String().replaceAll(".", dotReplace)).set({"text": text, "name": name});


    // DO NOT ADD TO MESSAGESAVES
    // The database will update, causing a listener to trigger and insert it
//    setState(() {
//      _messageSaves.add(message);
//   });

    message.animationController.forward();
  }

  @override
  void dispose() {
    mainRefSubscription.cancel();
    for (ChatMessage message in _messageSaves)
      message.animationController.dispose();
    super.dispose();
  }
}