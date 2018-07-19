import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:bodt_chat/groups/groupsListItem.dart';
import 'newGroupDialog.dart';
import 'confirmDeleteDialog.dart';
import '../chatScreen.dart';
import '../main.dart';

class GroupsListScreen extends StatefulWidget {
  GroupsListScreen({this.user});
  final FirebaseUser user;

  @override
  State createState() => new GroupsListScreenState(user);
}

class GroupsListScreenState extends State<GroupsListScreen> with TickerProviderStateMixin {
  FirebaseUser user;
  DatabaseReference mainRef;
  StreamSubscription<Event> addSub, deleteSub;
  bool canSub = false;

  final int growAnimationDuration = 700;
  final List<GroupsListItem> _groups = [];

  GroupsListScreenState(FirebaseUser user){
    this.user = user;
    FirebaseDatabase db = FirebaseDatabase.instance;
    db.setPersistenceEnabled(true);

    mainRef = db.reference();
    mainRef.keepSynced(true);
    addSub = mainRef.onChildAdded.listen((Event event) => _onGroupAdded(event.snapshot.key));
    deleteSub = mainRef.onChildRemoved.listen((Event event) => _onGroupDeleted(event.snapshot.key));
  }

  void _onGroupDeleted(String groupName){
    GroupsListItem group = _groups.firstWhere((GroupsListItem item) => item.name == groupName);

    group.animationController.addStatusListener((AnimationStatus status){
      if (status == AnimationStatus.dismissed)
        setState(() {
          _groups.remove(group);
        });
    });
    group.animationController.reverse();
  }

  void _onGroupAdded(String groupName){
    print("Chat added");
    StreamSubscription las;
    las = mainRef.child(groupName)
      .child(BodtChatApp.messagesChild)
      .limitToLast(1)
      .onChildAdded
      .listen((Event ev) {

        las.cancel();

        // Remove any earlier copies
        setState(() {
          for (GroupsListItem group in _groups)
            if (group.name == groupName){
              _groups.remove(group);
              break;
            }
        });

        print("Raw time: " + ev.snapshot.key);

        GroupsListItem group = new GroupsListItem(
          rawTime: ev.snapshot.key,
          name: groupName,
          startGroup: startGroup,
          deleteGroup: deleteGroup,
          animationController: new AnimationController(
            duration: new Duration(milliseconds: growAnimationDuration),
            vsync: this
          ),
        );
        group.animationController.forward();

        // Add the group and sort
        setState(() {
          _groups.add(group);
          _groups.sort((GroupsListItem i1, GroupsListItem i2) => i2.compareTo(i1));
        });
      });
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        appBar: new AppBar(
          title: new Text("Groups"),
          // No elevation if its on ios
          elevation: Theme.of(context).platform == TargetPlatform.iOS ? 0.0 : 4.0,
        ),
        body: new Container(
          child: _groups.length > 0 ? new ListView.builder(
            padding: new EdgeInsets.only(top: 8.0, bottom: 8.0),
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
          onPressed: () => showDialog(
              context: context,
              builder: (BuildContext context) => new NewGroupDialog(groups: _groups, addNewGroup: _addNewGroup)
          ),
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

  void startGroup(BuildContext context, String name) async {
    await Navigator.of(context).push(new MaterialPageRoute(
        builder: (context) => new ChatScreen(user: user, chatName: name)));

    // Force it to recalculate the clicked on chat when it returns here
/*
    setState(() {
      for(int c=0; c<_groups.length; c++)
        if (_groups[c].name == name){
          _groups.removeAt(c);
          break;
        }
    });
*/
    setState(() {
      for (GroupsListItem item in _groups){
        print("Item: " + item.name + " (" + item.time + ")");
      }
    });
    _onGroupAdded(name);
  }

  void _addNewGroup(String groupName){
    mainRef.child(groupName).set({
      BodtChatApp.messagesChild: {
        "0": {
          BodtChatApp.name: "System",
          BodtChatApp.text: "This is the beginning of your conversation in " + groupName
        }
      }
    });
  }

  void deleteGroup(BuildContext context, GroupsListItem group) {
    showDialog(
      context: context,
      builder: (BuildContext context) => new ConfirmDeleteDialog(group: group, deleteGroup: _finishDeleteGroup),
    );
  }

  void _finishDeleteGroup(GroupsListItem group) {
    mainRef.child(group.name).remove();
  }

  @override
  void dispose() {
    addSub.cancel();
    deleteSub.cancel();
    for (GroupsListItem message in _groups)
      message.animationController.dispose();
    super.dispose();
  }
}