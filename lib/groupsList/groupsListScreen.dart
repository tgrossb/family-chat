import 'dart:async';

import 'package:bodt_chat/constants.dart';
import 'package:bodt_chat/singleGroup/groupScreen.dart';
import 'package:bodt_chat/groupsList/confirmDeleteDialog.dart';
import 'package:bodt_chat/groupsList/groupsListItem.dart';
import 'package:bodt_chat/groupsList/newGroupDialog.dart';
import 'package:bodt_chat/routes.dart';
import 'package:bodt_chat/utils.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:bodt_chat/dataBundles.dart';
import 'package:bodt_chat/database.dart';

class GroupsListScreen extends StatefulWidget {
  GroupsListScreen();

  @override
  State createState() => new GroupsListScreenState();
}

class GroupsListScreenState extends State<GroupsListScreen> with TickerProviderStateMixin {
  DatabaseReference mainRef;
  StreamSubscription<Event> addSub, deleteSub, changeSub;
  bool canSub = false;

  List<GroupData> groupsData;
  Map<String, GlobalKey<GroupsListItemState>> _groupStateKeys = {};
  List<GroupsListItem> _groups = [];

  AnimationController fadeController;
  Animation fadeInAnimation;

  GroupsListScreenState() {
    this.groupsData = Database.groupFromName.values;
  }

  @override
  void initState() {
    super.initState();

    // First, order the groupsData based on last message time
    groupsData.sort((GroupData d1, GroupData d2) => d1.utcTime.difference(d2.utcTime).inMilliseconds);

    // Go through received data and add each group
    int c = 0;
    for (GroupData groupData in groupsData) {
      print("Recieved group data: " + groupData.toString());
      int groupPosition = groupsData.length - ++c;
      addGroupFromData(groupData, groupPosition * kGROUPS_LIST_ITEM_ANIMATION_OFFSET);
    }

    FirebaseDatabase db = FirebaseDatabase.instance;
    db.setPersistenceEnabled(true);

    mainRef = db.reference().child(kGROUPS_CHILD);
    mainRef.keepSynced(true);
    addSub = mainRef.onChildAdded
        .listen((Event event) => _onGroupAdded(event.snapshot));
    deleteSub = mainRef.onChildRemoved
        .listen((Event event) => _onGroupDeleted(event.snapshot.key));
    changeSub = mainRef.onChildChanged
        .listen((Event event) => _onGroupChanged(event.snapshot.key));

    fadeController = new AnimationController(
        vsync: this, duration: new Duration(milliseconds: 100));
    fadeInAnimation = new ColorTween(
            begin: kSPLASH_SCREEN_LOADING_COLOR,
            end: Color.fromARGB(0, 0, 0, 0))
        .animate(fadeController);
    fadeController.forward();
  }

  void addGroupFromData(GroupData data, int animationOffset) {
    var stateKey = new GlobalKey<GroupsListItemState>();
    GroupsListItem item = new GroupsListItem.fromData(
      key: stateKey,
      data: data,
      impData: new GroupImplementationData(
          start: startGroup,
          delete: deleteGroup,
          animationController: new AnimationController(
            vsync: this,
            duration:
                new Duration(milliseconds: kMESSAGE_GROW_ANIMATION_DURATION),
          )),
    );

    _groupStateKeys.putIfAbsent(data.name, () => stateKey);
    _groups.insert(0, item);
    item.startAnimation(msOffset: animationOffset);
  }

  void _onGroupChanged(String groupName) async {
    print("Begin changing group '$groupName'");

    var stateKey = _groupStateKeys[groupName];
    stateKey.currentState.setState(() {
      // Make clicks do nothing while loading new data
      // This will be changed once the new data is loaded
      stateKey.currentState
        ..impData.start = (){}
        ..impData.delete = (){};
    });

    GroupData data = await getGroupData(groupName);
    stateKey.currentState.setState((){
      // Restore functionality, update the data, and redo the animation
      stateKey.currentState
          ..data.utcTime = data.utcTime
          ..data.name = data.name
          ..impData.start = startGroup
          ..impData.delete = deleteGroup
          ..impData.animationController.forward(from: 0.0);
    });

    print("Finished changing group '$groupName'");
  }

  void _onGroupDeleted(String groupName) async {
    var group = _groupStateKeys[groupName].currentState;

    group.impData.animationController.addStatusListener((AnimationStatus status) {
      if (status == AnimationStatus.dismissed)
        setState(() {
          group.impData.animationController.dispose();
          group.dispose();
          _groups.removeWhere(
              (GroupsListItem item) => item.key.currentState.data.name == groupName);
          _groupStateKeys.remove(groupName);
        });
    });
    group.impData.animationController.reverse();
  }

  void _onGroupAdded(DataSnapshot snapshot) async {
    String groupName = snapshot.key;
    if (_groupStateKeys.containsKey(groupName)) {
      print("Rediscovered group: " + groupName + ", skipping");
      return;
    }
    Map v = snapshot.value;
    print("Length: " + v.length.toString());
    print("Chat added");
    var stateKey = new GlobalKey<GroupsListItemState>();
    GroupData data = await getGroupData(groupName);
    GroupsListItem item = new GroupsListItem.fromData(
      key: stateKey,
      data: data,
      impData: new GroupImplementationData(
        start: startGroup,
        delete: deleteGroup,
        animationController: new AnimationController(
            duration: new Duration(milliseconds: kMESSAGE_GROW_ANIMATION_DURATION),
            vsync: this
        ),
      ),
    );

    setState(() {
      _groupStateKeys.putIfAbsent(groupName, () => stateKey);
      _groups.insert(0, item);
      groupsData.insert(0, data);
    });

    item.impData.animationController.forward();
  }
/*
  void _handleGroupAdd(GlobalKey<GroupsListItemState> stateKey,
      String groupName, GroupsListItem item) async {
    GroupData data = await getGroupData(groupName, false);
    if (stateKey.currentState != null)
      stateKey.currentState.updateFromData(
          data: data,
          impData: new GroupImplementationData(
              start: startGroup, delete: deleteGroup));
    else
      // Mark this group as one that needs updating
      _toUpdate[stateKey] = data;

    print("Add finished");
  }
*/
  Future<GroupData> getGroupData(String groupName) async {
    Event event = await mainRef
        .child(groupName)
        .child(kMESSAGES_CHILD)
        .limitToLast(1)
        .onChildAdded
        .first;

    print("Raw time: " + event.snapshot.key);
    // TODO: Start loading the messages of the group
    return new GroupData.fromRawTime(rawTime: event.snapshot.key, name: groupName, firstMessages: null);
  }

/*
  void updateStates() {
    print("Updating states (length: " + _toUpdate.length.toString() + ")");
    _toUpdate.forEach((var stateKey, var data) {
      if (stateKey.currentState != null) {
        stateKey.currentState.updateFromData(
            data: data,
            impData: new GroupImplementationData(
                start: startGroup, delete: deleteGroup));
        print("Finishing " + stateKey.currentState.name);
      } else {
        print("Skipping 1 from null check");
      }
    });
    _toUpdate.clear();
  }
*/

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text("Groups"),
        // No elevation if its on ios
        elevation: Theme.of(context).platform == TargetPlatform.iOS ? 0.0 : 4.0,
      ),
      body: new Container(
          child: new Stack(
        children: <Widget>[
          _groups.length > 0
              ? new ListView.builder(
                  padding: new EdgeInsets.only(top: 8.0, bottom: 8.0),
                  reverse: false,
                  itemBuilder: (_, int index) => buildGroup(context, index),
                  itemCount: _groups.length,
                )
              : new Container(
                  alignment: Alignment.center,
                  child: new Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      new Text("No groups :(",
                          style: Theme.of(context).primaryTextTheme.title),
                      new Text("Lets get it started by creating one!",
                          style: Theme.of(context).primaryTextTheme.title)
                    ],
                  ),
                  decoration: Theme.of(context).platform == TargetPlatform.iOS
                      ? new BoxDecoration(
                          border: new Border(
                              top: new BorderSide(color: Colors.grey[200])))
                      : null,
                ),
          // TODO: Fix the flex thing
/*
          new Flex(
            direction: Axis.vertical,
//                  tag: "circleOut",
            children: <Widget>[
              new Expanded(
                  child: new Container(
                color: fadeInAnimation.value,
              ))
            ],
          )
*/
        ],
      )),
      floatingActionButton: new FloatingActionButton(
        backgroundColor: Theme.of(context).accentColor,
        child: new Icon(Icons.add),
        onPressed: () => showDialog(
            context: context,
            builder: (BuildContext context) => new NewGroupDialog(
                groups: _groupStateKeys, addNewGroup: _addNewGroup)),
      ),
    );
  }

  Widget buildGroup(BuildContext context, int index) {
    print("Constructing " +
        index.toString() +
        " from length " +
        _groupStateKeys.length.toString() +
        ", " +
        _groups.length.toString());
    return new Column(
        children: index == _groupStateKeys.length - 1
            ? <Widget>[_groups[index]]
            : <Widget>[_groups[index], new Divider(height: 1.0)]);
  }

  void startGroup(BuildContext context, String name) async {
    addSub.pause();
    deleteSub.pause();
    changeSub.pause();
//    await Navigator.of(context).push(new ListToGroupRoute(
//        builder: (context) => new ChatScreen(user: user, chatName: name)));

    // TODO: I don't know how i did this
    await Navigator.of(context).push(new SlideLeftRoute(
        widget: new GroupScreen(
            groupName: name,
            firstMessages: groupsData
                .firstWhere((data) => data.name == name)
                .firstMessages)
/*        new ChatScreen(user: user, chatName: name)*/));

    addSub.resume();
    deleteSub.resume();
    changeSub.resume();

    // _onGroupChanged should be triggered, so we don't need this
//    _onGroupAdded(name);
  }

  void _addNewGroup(String groupName) {
    DatabaseWriter.registerNewGroup(admins: [Database.me.uid], members: [Database.me.uid], groupName: groupName);
  }

  void deleteGroup(BuildContext context, GroupsListItemState group) {
    showDialog(
      context: context,
      builder: (BuildContext context) => new ConfirmDeleteDialog(
          group: group,

          // This will trigger the onChildDelete listener which will handle the rest
          deleteGroup: (GroupsListItemState group) => DatabaseWriter.removeGroup(group.data.name)),
    );
  }

  @override
  void dispose() {
    addSub.cancel();
    deleteSub.cancel();
    changeSub.cancel();
    for (GlobalKey<GroupsListItemState> stateKey in _groupStateKeys.values) {
      stateKey.currentState.impData.animationController.dispose();
      stateKey.currentState.dispose();
    }
    super.dispose();
  }
}