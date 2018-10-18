import 'dart:async';

import 'package:bodt_chat/constants.dart';
import 'package:bodt_chat/singleGroup/groupScreen.dart';
import 'package:bodt_chat/dialogs/confirmDeleteDialog.dart';
import 'package:bodt_chat/groupsList/groupsListItem.dart';
import 'package:bodt_chat/dialogs/newGroupDialog.dart';
import 'package:bodt_chat/widgetUtils/routes.dart';
import 'package:bodt_chat/utils.dart';
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
    _groupUids = _groupData.keys.toList();
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

    // You cant listen to the groups child on its own, as read access is limited
    mainRef = db.reference().child(DatabaseConstants.kGROUPS_LIST_CHILD);
    mainRef.keepSynced(true);
    addSub = mainRef.onChildAdded
        .listen((Event event) => _onGroupAdded(event.snapshot.key));
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

  void _onGroupChanged(String groupUid) async {
    print("Begin changing group $groupUid");

    GlobalKey stateKey = _groupStateKeys[groupUid];
    GroupsListItem item = stateKey.currentWidget;

    // Make clicks do nothing while loading new data
    // This will be changed once the new data is loaded
    item.disable();

    GroupData data = await DatabaseReader.loadSingleGroup(groupUid);

    // Restore functionality, update the data, and redo the animation
    item.setData(data);
    item.startAnimation();
    item.enable();

    print("Finished changing group $groupUid");
  }

  void _onGroupDeleted(String groupUid) async {
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

  void _onGroupAdded(String groupUid) async {
    // Skip over any keeper keys
    if (groupUid == DatabaseConstants.kKEEPER_KEY)
      return;

    if (_groupStateKeys.containsKey(groupUid)) {
      print("Rediscovered group: " + groupUid + ", skipping");
      return;
    }

    var stateKey = new GlobalKey<GroupsListItemState>();
    GroupData data = await DatabaseReader.loadSingleGroup(groupUid);
    GroupsListItem item = new GroupsListItem.fromData(
      key: stateKey,
      data: data,
      onClick: startGroup,
      onDelete: deleteGroup,
      controller: new AnimationController(
          duration: new Duration(milliseconds: kMESSAGE_GROW_ANIMATION_DURATION),
          vsync: this
      ),
    );

    setState(() {
      _groupStateKeys[groupUid] = stateKey;
      _groupData[groupUid] = data;
      _groups[groupUid] = item;
      _groupUids.insert(0, groupUid);
    });

    item.startAnimation();
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
    return new Column(
        children: index == _groupUids.length - 1
            ? <Widget>[_groups[_groupUids[index]]]
            : <Widget>[_groups[_groupUids[index]], new Divider(height: 1.0)]);
  }

  void startGroup(BuildContext context, GroupData data) async {
    addSub.pause();
    deleteSub.pause();
    changeSub.pause();
//    await Navigator.of(context).push(new ListToGroupRoute(
//        builder: (context) => new ChatScreen(user: user, chatName: name)));

    // TODO: I don't know how i did this
    await Navigator.of(context).push(new SlideLeftRoute(
        widget: new GroupScreen(data: data)
      /*        new ChatScreen(user: user, chatName: name)*/));

    addSub.resume();
    deleteSub.resume();
    changeSub.resume();

    // _onGroupChanged should be triggered, so we don't need this
//    _onGroupAdded(name);
  }


  // TODO: Update this and dialog for new group params
  void _addNewGroup(String groupName) {
    // For now, generate a random pastel color
    Color groupColor = Utils.mixRandomColor(Colors.white);
    GroupThemeData themeData = GroupThemeData(groupColor: groupColor);
    DatabaseWriter.registerNewGroup(admins: [Database.me.uid], members: [Database.me.uid], groupName: groupName, groupThemeData: themeData);
  }

  void deleteGroup(BuildContext context, GroupsListItemState group) {
    showDialog(
      context: context,
      builder: (BuildContext context) => new ConfirmDeleteDialog(
          group: group,

          // This will trigger the onChildDelete listener which will handle the rest
          deleteGroup: (GroupsListItemState group) => DatabaseWriter.removeGroup(group.data.uid)),
    );
  }

  @override
  void dispose() {
    addSub.cancel();
    deleteSub.cancel();
    changeSub.cancel();
    super.dispose();
  }
}