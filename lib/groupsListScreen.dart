import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'groupsListItem.dart';
import 'chatScreen.dart';
import 'main.dart';

class GroupsListScreen extends StatefulWidget {
  GroupsListScreen({this.user});
  final FirebaseUser user;

  @override
  State createState() => new GroupsListScreenState(user);
}

class GroupsListScreenState extends State<GroupsListScreen> with TickerProviderStateMixin {
  FirebaseUser user;
  DatabaseReference mainRef;
  StreamSubscription<Event> mainRefSubscription, lastAddSubscription;

  final int growAnimationDuration = 700;
  final List<GroupsListItem> _groups = [];

  GroupsListScreenState(FirebaseUser user){
    this.user = user;
    FirebaseDatabase db = FirebaseDatabase.instance;
    db.setPersistenceEnabled(true);

    mainRef = db.reference();
    mainRef.keepSynced(true);
    mainRefSubscription = mainRef.onChildAdded.listen((Event event) => _onChatAdded(event.snapshot.key));
  }

  void _onChatAdded(String groupName){
      print("Chat added");
      StreamSubscription las;
      las = mainRef.child(groupName)
          .child(BodtChatApp.messagesChild)
          .limitToLast(1)
          .onChildAdded
          .listen((Event ev) => finishAddingChat(ev, groupName, las));

    }

  void finishAddingChat(Event event, String groupName, StreamSubscription<Event> las){
    las.cancel();

    // Remove any earlier copies
    setState(() {
      _groups.removeWhere((GroupsListItem item) => item.name == groupName);
    });

    GroupsListItem group = new GroupsListItem(
      time: GroupsListItem.formatTime(event.snapshot.key),
      rawTime: event.snapshot.key,
      name: groupName,
      startChat: startChat,
      animationController: new AnimationController(
        duration: new Duration(milliseconds: growAnimationDuration),
        vsync: this
      ),
    );
    group.animationController.forward();

    setState(() {
      int startLength = _groups.length;
      if (startLength == 0) {
        _groups.add(group);
      } else {
        for (int c = 0; c < startLength; c++)
          if (group.after(_groups[c])) {
            _groups.insert(c, group);
            break;
          }
      }
      // If this is true, a new group has not been added, so it is the earliest
      if (startLength == _groups.length) {
        _groups.add(group);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        appBar: new AppBar(
          title: new Text("Chats"),
          // No elevation if its on ios
          elevation: Theme.of(context).platform == TargetPlatform.iOS ? 0.0 : 4.0,
        ),
        body: new Container(
          child: _groups.length > 0 ? new ListView.builder(
            padding: new EdgeInsets.all(8.0),
            reverse: false,
            itemBuilder: (_, int index) => buildGroup(context, index),
            itemCount: _groups.length,
          ) : new Container(
            alignment: Alignment.center,
            child: new Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                new Text("No groups :(", style: Theme.of(context).primaryTextTheme.title),
                new Text("Lets get it started by creating one!", style: Theme.of(context).primaryTextTheme.title)
              ],
            )
          ),

          decoration: Theme.of(context).platform == TargetPlatform.iOS ?
          new BoxDecoration(border: new Border(top: new BorderSide(color: Colors.grey[200]))) : null
        ),

        floatingActionButton: new FloatingActionButton(
          backgroundColor: Theme.of(context).accentColor,
          child: new Icon(Icons.add),
          onPressed: showInputDialog
        ),
    );
  }

  Widget buildGroup(BuildContext context, int index){
    return new Column(
      children: index == _groups.length-1 ?
        <Widget>[_groups[index]] :
        <Widget>[_groups[index], new Divider(height: 1.0)]
    );
  }

  void showInputDialog() {
    String groupName;
    bool canSub = false;

    showDialog(
      context: context,
      builder: (BuildContext context) => new AlertDialog(
        title: new Text("Add New Group"),
        content: new TextField(
          decoration: new InputDecoration(
            labelText: "Group Name",
            isDense: true,
          ),
          onChanged: (String text){
            groupName = text;
            setState(() {
              canSub = groupName.length > 0;
              if (canSub)
                for (GroupsListItem item in _groups)
                  if (item.name == groupName){
                    canSub = false;
                    break;
                  }
            });
            print("Can sub: " + canSub.toString());
          }
        ),

        actions: <Widget>[
          new FlatButton(
            child: new Text("Cancel"),
            onPressed: () => Navigator.pop(context),
          ),

          new FlatButton(
            child: new Text("Add"),
            onPressed: canSub ? () => _addNewGroup(context, groupName) : null,
          )
        ],
      )
    );
  }

  void _addNewGroup(BuildContext context, String groupName){
    Navigator.pop(context);
    mainRef.child(groupName).set({
      BodtChatApp.messagesChild: {
        "0": {
          BodtChatApp.name: "System",
          BodtChatApp.text: "This is the beginning of your conversation in " + groupName
        }
      }
    });
  }

  void startChat(BuildContext context, String name) async {
    await Navigator.of(context).push(new MaterialPageRoute(
        builder: (context) => new ChatScreen(user: user, chatName: name)));

    // Force it to recalculate the clicked on chat when it returns here
    _onChatAdded(name);
  }

  @override
  void dispose() {
    mainRefSubscription.cancel();
    for (GroupsListItem message in _groups)
      message.animationController.dispose();
    super.dispose();
  }
}