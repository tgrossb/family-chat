import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:bodt_chat/groups/groupsListItem.dart';
import './groupsListItem.dart';
import './newGroupDialog.dart';
import './confirmDeleteDialog.dart';
import './slideRoute.dart';
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
  StreamSubscription<Event> addSub, deleteSub, changeSub;
  bool canSub = false;

  final int growAnimationDuration = 700;
  Map<String, GlobalKey<GroupsListItemState>> _groupStateKeys = {};
  List<GroupsListItem> _groups = [];
  Map<GlobalKey<GroupsListItemState>, GroupData> _toUpdate = {};

  GroupsListScreenState(FirebaseUser user) {
    this.user = user;
  }

  @override
  void initState(){
    super.initState();

    FirebaseDatabase db = FirebaseDatabase.instance;
    db.setPersistenceEnabled(true);

    mainRef = db.reference();
    mainRef.keepSynced(true);
    addSub = mainRef.onChildAdded.listen((Event event) => _onGroupAdded(event.snapshot));
    deleteSub = mainRef.onChildRemoved.listen((Event event) => _onGroupDeleted(event.snapshot.key));
    changeSub = mainRef.onChildChanged.listen((Event event) => _onGroupChanged(event.snapshot.key));
  }

  void _onGroupChanged(String groupName) {
    print("Group change");
    var stateKey = _groupStateKeys[groupName];
    stateKey.currentState.setState(() {
      // Set displayed things to empty and make clicks do nothing
      // This will be changed once the new data is loaded
      stateKey.currentState
          ..time = ""
          ..name = ""
          ..start = (){};
    });
    handleGroupChange(stateKey, groupName);
  }

  void handleGroupChange(GlobalKey<GroupsListItemState> stateKey, String groupName) async {
    // On change, just recalculate the group info and redo the animation
    GroupData data = await getGroupData(groupName);
    setState(() {
      stateKey.currentState
          ..utcTime = GroupsListItem.parseTime(data.rawTime)
          ..time = GroupsListItem.formatTime(data.rawTime)
          ..name = data.name
          ..animationController.forward(from: 0.0);
    });
    print("Group change finished");
  }

  void _onGroupDeleted(String groupName) {
    var group = _groupStateKeys[groupName].currentState;

    group.animationController.addStatusListener((AnimationStatus status){
      if (status == AnimationStatus.dismissed)
        setState(() {
          group.animationController.dispose();
          group.dispose();
          _groups.removeWhere((GroupsListItem item) => item.key.currentState.name == groupName);
          _groupStateKeys.remove(groupName);
        });
    });
    group.animationController.reverse();
  }

  void _onGroupAdded(DataSnapshot snapshot){
    String groupName = snapshot.key;
    Map v = snapshot.value;
    print("Length: " + v.length.toString());
    print("Chat added");
    var stateKey = new GlobalKey<GroupsListItemState>();
    GroupsListItem item = new GroupsListItem(
      key: stateKey,
      rawTime: "0",
      name: groupName,
      start: (){},
      delete: (){},
      animationController: new AnimationController(
          duration: new Duration(milliseconds: growAnimationDuration),
          vsync: this
      ),
    );

    // Force it to create a state in case handleAdd happens before a rebuilt
//    item.createState();

    setState(() {
      _groupStateKeys.putIfAbsent(groupName, () => stateKey);
      _groups.insert(0, item);
    });

    item.animationController.forward();
    _handleGroupAdd(stateKey, groupName, item);
  }

  void _handleGroupAdd(GlobalKey<GroupsListItemState> stateKey, String groupName, GroupsListItem item) async {
    GroupData data = await getGroupData(groupName, false);
    if (stateKey.currentState != null)
      stateKey.currentState.updateFromData(data: data);
    else
      // Mark this group as one that needs updating
      _toUpdate[stateKey] = data;

    print("Add finished");
  }

  Future<GroupData> getGroupData([String groupName, bool includeName = true]) async {
    Event event = await mainRef.child(groupName).child(BodtChatApp.messagesChild).limitToLast(1).onChildAdded.first;

    print("Raw time: " + event.snapshot.key);
    return new GroupData(rawTime: event.snapshot.key, name: groupName, start: startGroup, delete: deleteGroup);
  }

  void updateStates(){
    print("Updating states (length: " + _toUpdate.length.toString() + ")");
    _toUpdate.forEach((var stateKey, var data){
      stateKey.currentState.updateFromData(data: data);
      print("Finishing " + stateKey.currentState.name);
    });
    _toUpdate.clear();
  }

  @override
  Widget build(BuildContext context) {
    Widget res = new Scaffold(
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
              builder: (BuildContext context) => new NewGroupDialog(groups: _groupStateKeys, addNewGroup: _addNewGroup)
          ),
        ),
    );
    // Update anything that needs to be updated now that all have been added to the tree
    updateStates();
    return res;
  }

  Widget buildGroup(BuildContext context, int index){
    print("Constructing " + index.toString() + " from length " + _groupStateKeys.length.toString() + ", " + _groups.length.toString());
    return new Column(
      children: index == _groupStateKeys.length-1 ?
        <Widget>[_groups[index]] :
        <Widget>[_groups[index], new Divider(height: 1.0)]
    );
  }

  void startGroup(BuildContext context, String name) async {
    addSub.pause();
    deleteSub.pause();
    changeSub.pause();
//    await Navigator.of(context).push(new ListToGroupRoute(
//        builder: (context) => new ChatScreen(user: user, chatName: name)));

    await Navigator.of(context).push(new SlideLeftRoute(widget: new ChatScreen(user: user, chatName: name)));

    addSub.resume();
    deleteSub.resume();
    changeSub.resume();

    // _onGroupChanged should be triggered, so we don't need this
//    _onGroupAdded(name);
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

  void deleteGroup(BuildContext context, GroupsListItemState group) {
    showDialog(
      context: context,
      builder: (BuildContext context) => new ConfirmDeleteDialog(group: group, deleteGroup: _finishDeleteGroup),
    );
  }

  void _finishDeleteGroup(GroupsListItemState group) {
    // This will trigger the onChildDelete listener which will handle the rest
    mainRef.child(group.name).remove();
  }

  @override
  void dispose() {
    addSub.cancel();
    deleteSub.cancel();
    changeSub.cancel();
    for (GlobalKey<GroupsListItemState> stateKey in _groupStateKeys.values) {
      stateKey.currentState.animationController.dispose();
      stateKey.currentState.dispose();
    }
    super.dispose();
  }
}