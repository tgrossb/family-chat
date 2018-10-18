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
  DatabaseReference mainRef;
  StreamSubscription<Event> mainRefSubscription;

  final TextEditingController _textController = new TextEditingController();
  bool _isWriting = false;

  // Requires the loaded data and sets up a subscription to get new data
  GroupScreenState({@required this.data});

  // Get the reference to the database for this group
  // Also, put preloaded messages into _messageSaves and start their
  // animations while older messages load.
  @override
  void initState(){
    super.initState();
    FirebaseDatabase db = FirebaseDatabase.instance;
    db.setPersistenceEnabled(true);

    mainRef = db.reference().child(DatabaseConstants.kGROUPS_CHILD).child(data.uid);
    mainRef.keepSynced(true);
    mainRefSubscription = mainRef.onChildAdded.listen(_onMessageAdded);

    for (MessageData data in Database.groupFromName[groupName].firstMessages) {
      GroupMessage message = new GroupMessage.fromData(
          data: data,
          myName: Database.me.name,
          animationController: new AnimationController(
              vsync: this,
              duration: new Duration(
                  milliseconds: kMESSAGE_GROW_ANIMATION_DURATION)
          )
      );
      _messageSaves.insert(0, message);
      message.animationController.forward();
    }
  }

  // Handles the gui side of a new message being added to the database.
  // Parses the event snapshot into the necessary message data and stores it,
  // as well as starting the animation.
  void _onMessageAdded(Event event){
    MessageData data = new MessageData(
      text: event.snapshot.value['text'],
      name: event.snapshot.value['name'],
      utcTime: Utils.parseTime(event.snapshot.key)
    );

    // If this message has already been handled (preloaded), skip over it
    if (_messageSaves.any((message) => message.data == data))
      return;

    GroupMessage message = new GroupMessage.fromData(
      data: data,
      myName: Database.me.name,
      animationController: new AnimationController(
        duration: new Duration(milliseconds: kMESSAGE_GROW_ANIMATION_DURATION),
        vsync: this
      ),
    );

    // Insert the message at the front of the array
    setState(() {
      _messageSaves.insert(0, message);
    });

    // Start the enter animation for the message
    // TODO: Change GroupMessage to an AnimatedWidget?
    message.animationController.forward();
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        appBar: new AppBar(
          title: new Text(groupName),
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
        groupName: groupName,
        message: MessageData(text: text, name: Database.me.name, utcTime: DateTime.now()));


    // DO NOT ADD TO _messageSaves OR START THE ANIMATION
    // The database will update, causing a listener to trigger and
    // handle the gui and adding (_onMessageAdded).
  }

  // Cancel all subscriptions and dispose of all animation controllers
  @override
  void dispose() {
    mainRefSubscription.cancel();
    for (GroupMessage message in _messageSaves)
      message.animationController.dispose();
    super.dispose();
  }
}