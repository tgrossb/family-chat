import 'dart:async';

import 'package:bodt_chat/constants.dart';
import 'package:bodt_chat/singleGroup/groupScreen.dart';
import 'package:bodt_chat/dialogs/confirmDeleteDialog.dart';
import 'package:bodt_chat/groupsList/groupsListItem.dart';
import 'package:bodt_chat/dialogs/newGroupDialog.dart';
import 'package:bodt_chat/widgetUtils/routes.dart';
import 'package:bodt_chat/utils.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:bodt_chat/dataUtils/dataBundles.dart';
import 'package:bodt_chat/dataUtils/database.dart';

class GroupsListScreen extends StatefulWidget {
  GroupsListScreen();

  @override
  State createState() => new GroupsListScreenState();
}

class GroupsListScreenState extends State<GroupsListScreen> with TickerProviderStateMixin {
  DatabaseReference mainRef;
  StreamSubscription<Event> addSub, deleteSub, changeSub;
  bool canSub = false;

  // This list holds the order for map keys
  List<String> _groupUids;

  Map<String, GroupData> _groupData;
  Map<String, GlobalKey<GroupsListItemState>> _groupStateKeys = {};
  Map<String, GroupsListItem> _groups = {};

  AnimationController fadeController;
  Animation fadeInAnimation;

  @override
  void initState() {
    // Order the groups by their last message timestamp
    _groupData = Map.of(Database.groupFromUid);
    _groupUids.sort((String d1, String d2) => _groupData[d1].utcTime.difference(_groupData[d2].utcTime).inMilliseconds);

    // Go through received data and add each group
    int c = 0;
    for (String groupUid in _groupUids) {
      GroupData data = _groupData[groupUid];
      print("Recieved group data: " + data.toString());
      int groupPosition = _groupUids.length - ++c;
      addGroupFromData(data, groupPosition * kGROUPS_LIST_ITEM_ANIMATION_OFFSET);
    }

    FirebaseDatabase db = FirebaseDatabase.instance;
    db.setPersistenceEnabled(true);

    mainRef = db.reference().child(DatabaseConstants.kGROUPS_LIST_CHILD);
    mainRef.keepSynced(true);
    addSub = mainRef.onChildAdded
        .listen((Event event) => _onGroupAdded(event.snapshot));
    deleteSub = mainRef.onChildRemoved
        .listen((Event event) => _onGroupDeleted(event.snapshot));
    changeSub = mainRef.onChildChanged
        .listen((Event event) => _onGroupChanged(event.snapshot));

    fadeController = new AnimationController(
        vsync: this, duration: new Duration(milliseconds: 100));
    fadeInAnimation = new ColorTween(
            begin: kSPLASH_SCREEN_LOADING_COLOR,
            end: Color.fromARGB(0, 0, 0, 0))
        .animate(fadeController);
    fadeController.forward();

    super.initState();
  }

  // The group should already be present in the _groupData map and the _groupUids list
  void addGroupFromData(GroupData data, int animationOffset) {
    var stateKey = new GlobalKey<GroupsListItemState>();
    GroupsListItem item = new GroupsListItem.fromData(
      key: stateKey,
      data: data,
      onClick: startGroup,
      onDelete: deleteGroup,
      controller: new AnimationController(
       vsync: this,
       duration:
         new Duration(milliseconds: kMESSAGE_GROW_ANIMATION_DURATION),
      )
    );

    _groupStateKeys[data.uid] = stateKey;
    _groups[data.uid] = item;
    item.startAnimation(msOffset: animationOffset);
  }

  void _onGroupChanged(DataSnapshot snap) async {
    String groupUid = snap.key;
    print("Begin changing group $groupUid");

    GlobalKey stateKey = _groupStateKeys[groupUid];
    GroupsListItem item = stateKey.currentWidget;

    // Make clicks do nothing while loading new data
    // This will be changed once the new data is loaded
    item.disable();

    GroupData data = GroupData.fromSnapshot(snap: snap);
    // Restore functionality, update the data, and redo the animation
    item.setData(data);
    item.startAnimation();
    item.enable();

    print("Finished changing group $groupUid");
  }

  void _onGroupDeleted(DataSnapshot snap) async {
    String groupUid = snap.key;
    var group = _groupStateKeys[groupUid].currentState;

    group.controller.addStatusListener((AnimationStatus status) {
      if (status == AnimationStatus.dismissed)
        setState(() {
          group.dispose();
          _groupUids.remove(groupUid);
          _groupData.remove(groupUid);
          _groups.remove(groupUid);
          _groupStateKeys.remove(groupUid);
        });
    });
    group.controller.reverse();
  }

  void _onGroupAdded(DataSnapshot snap) async {
    String groupName = snap.key;
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