/**
 * This is the screen for an entire group.  This is where the
 * messages of the group are displayed.
 *
 * TODO: Add an events tab style thing to the group screen (big)
 *
 * Group messages are loaded asynchronously, but the first few
 * messages (~10) should be preloaded in the initial loading stage
 * so the user isn't left waiting when the group screen launches.
 *
 * Written by: Theo Grossberndt
 */

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:bodt_chat/singleGroup/groupMessage.dart';
import 'package:bodt_chat/constants.dart';
import 'package:bodt_chat/utils.dart';
import 'package:bodt_chat/dataUtils/dataBundles.dart';
import 'package:bodt_chat/dataUtils/database.dart';

class GroupScreen extends StatefulWidget {
  GroupScreen({@required this.data});
  final GroupData data;

  @override
  State createState() => new GroupScreenState(data: data);
}

class GroupScreenState extends State<GroupScreen> with TickerProviderStateMixin {
  GroupData data;
  StreamSubscription<Event> messageAddedSub, messageDeletedSub;
  StreamSubscription<Event> nameChangedSub;
  StreamSubscription<Event> themeChangedSub;
  List<GroupMessage> _messages;

  final TextEditingController _textController = new TextEditingController();
  bool _isWriting = false;

  GroupScreenState({@required this.data});

  @override
  void initState(){
    FirebaseDatabase db = FirebaseDatabase.instance;
    db.setPersistenceEnabled(true);

    // Set up the message added and deleted subs
    DatabaseReference groupRef = Database.database.reference().child("${DatabaseConstants.kGROUPS_CHILD}/${data.uid}");
    messageAddedSub = groupRef.child(DatabaseConstants.kGROUP_MESSAGES_CHILD).onChildAdded.listen(onMessageAdded);
    messageDeletedSub = groupRef.child(DatabaseConstants.kGROUP_MESSAGES_CHILD).onChildRemoved.listen(onMessageDeleted);

    // Set up the name changed sub
    nameChangedSub = groupRef.child(DatabaseConstants.kGROUP_NAME_CHILD).onChildChanged.listen(onNameChanged);

    // Set up the theme changed sub
    themeChangedSub = groupRef.child(DatabaseConstants.kGROUP_THEME_DATA_CHILD).onChildChanged.listen(onThemeChanged);

    _messages = [];
    for (MessageData data in data.messages) {
      GroupMessage message = new GroupMessage.fromData(
        data: data,
        animationController: new AnimationController(
          vsync: this,
          duration: new Duration(milliseconds: kMESSAGE_GROW_ANIMATION_DURATION)
        ),
        themeData: this.data.groupThemeData,
      );
      _messages.add(message);
      message.animationController.forward();
    }

    super.initState();
  }

  // Handles the gui side of a new message being added to the database.
  // Parses the event snapshot into the necessary message data and stores it,
  // as well as starting the animation.
  void onMessageAdded(Event event) async {
    MessageData data = MessageData.fromSnapshot(snap: event.snapshot);

    // If this message has already been handled (preloaded), skip over it
    if (_messages.any((message) => message.data == data)) {
      print("Skipping ${event.snapshot.key}");
      return;
    }
    print("Handling ${event.snapshot.key}");

    GroupMessage message = new GroupMessage.fromData(
      data: data,
      animationController: new AnimationController(
        duration: new Duration(milliseconds: kMESSAGE_GROW_ANIMATION_DURATION),
        vsync: this
      ),
      themeData: this.data.groupThemeData,
    );

    // Insert the message at the front of the array
    setState(() {
      _messages.add(message);
    });

    // Start the enter animation for the message
    message.animationController.forward();
  }

  void onMessageDeleted(Event event) async {
    String messageTime = event.snapshot.key;
    setState(() {
      _messages.removeWhere((message) => Utils.timeToKeyString(message.data.utcTime) == messageTime);
    });
  }

  void onNameChanged(Event event) async {
    setState(() {
      data.name = event.snapshot.value;
    });
  }

  void onThemeChanged(Event event) async {
    setState(() {
      data.groupThemeData.updateFromChangeSnapshot(event.snapshot);
      for (GroupMessage message in _messages)
        message.setThemeData(data.groupThemeData);
    });
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        appBar: new AppBar(
          title: new Text(data.name, style: Theme.of(context).primaryTextTheme.title.copyWith(color: Utils.pickTextColor(data.groupThemeData.accentColor)),),
          // No elevation if its on ios
          elevation: Theme.of(context).platform == TargetPlatform.iOS ? 0.0 : 4.0,
          backgroundColor: data.groupThemeData.accentColor,
        ),
        body: new Container(
            child: new Column(
              children: <Widget>[
                 new Flexible(
                   child: new ListView.builder(
                     padding: new EdgeInsets.all(8.0),
                     reverse: true,
                     itemBuilder: (_, int index) => _messages[_messages.length - 1 - index],
                     itemCount: _messages.length,
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

  // Builds the 'Send a message' text input field where
  // the user inputs a message.
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

  // Handles when the send button is clicked or when the TextField
  // for the input receives an onSubmitted event.
  void _handleSubmitted(String text) {
    _textController.clear();
    setState(() {
      _isWriting = false;
    });

    DatabaseWriter.addMessage(
        groupUid: data.uid,
        message: MessageData(text: text, senderUid: Database.me.uid, utcTime: DateTime.now()));


    // DO NOT ADD TO _messageSaves OR START THE ANIMATION
    // The database will update, causing a listener to trigger and
    // handle the gui and adding (_onMessageAdded).
  }

  // Cancel all subscriptions and dispose of all animation controllers
  @override
  void dispose() {
    messageAddedSub.cancel();
    messageDeletedSub.cancel();
    nameChangedSub.cancel();
    themeChangedSub.cancel();
    super.dispose();
  }
}