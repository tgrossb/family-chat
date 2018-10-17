/*
 * This is an abstraction of the firebase database so databases are **ideally** plug and play.
 * This class should be the only thing that needs to be changed if the database structure or the
 * database itself changes.
 *
 * One database object will be created when loading begins, and this database will be passed around
 * and send data as it comes.
 *
 * Written by: Theo Grossberndt
 *
 *
 * TODO Fix chunked methods, they don't work
 */

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:bodt_chat/constants.dart';
import 'package:bodt_chat/utils.dart';
import 'package:bodt_chat/dataUtils/user.dart';
import 'package:bodt_chat/dataUtils/dataBundles.dart';

/*
 * Database data lives here
 *
 * Data is read by methods in the DatabaseReader class and stored here
 *
 * Note: Please, just don't edit these unless you know what you are doing.
 * Leave that to the DatabaseReader and DatabaseWriter classes
 */
class Database {
  static final FirebaseDatabase database = FirebaseDatabase.instance;

  // TODO: I don't think that this is needed or useful
  //  static ResponsibleList sudoerUids = ResponsibleList();

  static List<String> userUids = List();
  static Map<String, User> userFromUid = {};
  static User me;
  static ResponsibleList groupUids = ResponsibleList(key: DatabaseConstants.kGROUPS_LIST_CHILD);
  static Map<String, GroupData> groupFromUid = {};

//  get groups => groupFromName.values;
//  get users => userFromUid.values;
}

class DatabaseWriter {
  // Sets a database child's value and checks if the operation was successful
  static Future<bool> performCheckedSet(String path, var value) async {
    bool successful = true;
    await Database.database.reference().child(path).set(value).catchError((e){
      successful = false;
      throw e;
    });

    return successful;
  }

  // Adds the map definition of a child to the database at the supplied path
  // Uses checked operations
  static Future<bool> appendChild(String path, Map child) async {
    // Ensure that the child only has one root key
    assert(child.keys.length == 1);

    String childRoot = child.keys.toList()[0];
    return await performCheckedSet("$path/$childRoot", child[childRoot]);
  }

  static Future<bool> registerNewUser({@required Me me}) async {
    bool successful = await appendChild(DatabaseConstants.kUSERS_CHILD, me.toDatabaseChild());
    if (!successful)
      return false;
    successful = await appendChild(DatabaseConstants.kUSERS_LIST_CHILD, {me.uid: "uid"});
    if (!successful)
      return false;

    // Update the database class to reflect this change
    Database.userUids.add(me.uid);
    Database.userFromUid[me.uid] = me;

    return true;
  }

  // This user must be a registered user, and the current user must be a sudoer
  // These stipulations are verified by database rules, so there's no need to check them here
  static Future<bool> registerNewSudoer({@required User user}) async {
    bool successful = await appendChild(DatabaseConstants.kSUDOERS_CHILD, {user.uid: Database.me.uid});
    if (!successful)
      return false;

    // Update the database class to reflect this change
//    Database.sudoerUids.addEntry(user.uid, Database.me.uid);

    return true;
  }

  static Future<bool> registerNewGroup({@required List<String> admins, @required List<String> members,
                                            @required String groupName, @required GroupThemeData groupThemeData}) async {
    // Check that the group admins and members section contains me
    if (!admins.contains(Database.me.uid))
      admins.add(Database.me.uid);
    if (!members.contains(Database.me.uid))
      members.add(Database.me.uid);

    // Construct responsible lists from the admins and members list with me being responsible for each
    String responsible = Database.me.uid;
    ResponsibleList adminsResList = ResponsibleList(key: DatabaseConstants.kGROUP_ADMINS_CHILD);
    ResponsibleList membersResList = ResponsibleList(key: DatabaseConstants.kGROUP_MEMBERS_CHILD);
    for (String adminUid in admins)
      adminsResList.addEntry(adminUid, responsible);
    for (String memberUid in members)
      membersResList.addEntry(memberUid, responsible);

    DateTime utcTime = DateTime.now().toUtc();
    // Give it a non-unique uid for now
    // A real uid will be generated when it is pushed, and the uid will then be updated
    GroupData groupData = GroupData(
      uid: "0",
      utcTime: utcTime,
      name: groupName,
      admins: adminsResList,
      members: membersResList,
      groupThemeData: groupThemeData,
      messages: [MessageData(text: "${Database.me.name} created the group $groupName", senderUid: "System", utcTime: utcTime)]
    );

    bool successful = true;
    DatabaseReference groupLoc = Database.database.reference().child(DatabaseConstants.kGROUPS_CHILD).push();
    await groupLoc.set(groupData.toDatabaseChild().values).catchError((e){
      successful = false;
      throw e;
    });

    if (!successful)
      return false;

    // Update the uid to be the generated uid
    groupData.uid = groupLoc.key;
    
    successful = await appendChild(DatabaseConstants.kGROUPS_LIST_CHILD, {groupData.name: Database.me.uid});
    if (!successful)
      return false;

    // Update the database class to reflect this change
    Database.groupUids.addEntry(groupData.uid, Database.me.uid);
    Database.groupFromUid[groupData.uid] = groupData;

    return true;
  }

  static Future<bool> removeGroup(String groupUid) async {
    bool successful = true;
    await Database.database.reference().child("${DatabaseConstants.kGROUPS_CHILD}/$groupUid").remove().catchError((e){
      successful = false;
      throw e;
    });

    if (!successful)
      return false;

    // Update the database class to reflect this change
    Database.groupUids.removeEntry(groupUid);
    Database.groupFromUid.removeWhere((String uid, GroupData data) => uid == groupUid);

    return true;
  }

  static Future<bool> addMessage({@required String groupUid, @required MessageData message}) async {
    String path = "${DatabaseConstants.kGROUPS_CHILD}/$groupUid/${DatabaseConstants.kGROUP_MESSAGES_CHILD}";
    bool successful = await appendChild(path, message.toDatabaseChild());
    if (!successful)
      return false;

    // Update the database class to reflect this change
    Database.groupFromUid[groupUid].messages.insert(0, message);

    return true;
  }
}

class DatabaseReader {
  // Loads a child from the database, and returns null if an error is encountered
  static Future<DataSnapshot> loadChild([String location, bool order = false]) async {
    DatabaseReference ref = Database.database.reference().child(location);
    DataSnapshot snap;

    Function onError = (e){
      snap = null;
      print("Found error: $e");
      throw e;
    };

    if (order)
      snap = await ref.orderByKey().once().catchError(onError);
    else
      snap = await ref.once().catchError(onError);
    return snap;
  }

  // Gets all of the keys from a datasnapshot's values
  // Ex) If this is the child in the snapshot:
  //     "users": {
  //       "abcdefgh": "uid",
  //       "12345678": "uid"
  //      }
  // Then this will return ["abcdefgh", "12345678"]
  static List<String> scrapeSnapshotKeys(DataSnapshot snap){
    List<String> keys = [];
    for (String key in snap.value.keys)
      keys.add(key);
    return keys;
  }

  // Checks if a user exists by querying a test child
  // This query will raise an error if the user doesn't exist
  static Future<bool> userExists() async {
    DataSnapshot snap = await loadChild(DatabaseConstants.kUSER_EXISTS_TEST);
    if (snap == null)
      print("User does not exist");
    return snap != null;
  }

  // Loads a list of all sudoers' uids in the database
//  static Future<ResponsibleList> loadSudoerUids() async {
//    DataSnapshot sudoersSnap = await loadFullChild(DatabaseConstants.kSUDOERS_CHILD);
//    print("Loading sudoers, snapped value: " + sudoersSnap.value.toString() + ", snapped key: " + sudoersSnap.key.toString());
//
//    Database.sudoerUids = scrapeSnapshotKeys(sudoersSnap);
//    return Database.sudoerUids;
//  }

  // Loads a list of all users in the database without their data
  static Future<List<String>> loadUserUids() async {
    DataSnapshot usersSnap = await loadChild(DatabaseConstants.kUSERS_LIST_CHILD);
    if (usersSnap == null) {
      print("Error loading user uids");
      return null;
    }

    Database.userUids = scrapeSnapshotKeys(usersSnap);
    return Database.userUids;
  }

  // Loads all of the public data of all users in the database
  static Future<List<User>> loadUsers(String myUid) async {
    // We have to query specific uids because of the database rules, so make sure they have been loaded
    if (Database.userUids == null || Database.userUids.length == 0)
      await loadUserUids();

    Database.userFromUid = {};

    for (String uid in Database.userUids) {
      // If the uid is me, don't add it
      // We'll handle my data later
      if (uid == myUid)
        continue;

      // Query the public data of each user
      // Access is denied to private data, so this is not the only defense
      DataSnapshot userSnap = await loadChild("${DatabaseConstants.kUSERS_CHILD}/$uid/${DatabaseConstants.kUSER_PUBLIC_VARS}");
      if (userSnap == null){
        print("Error loading user public data");
        return null;
      }

      // Convert each user to a User object and add it to the map
      Database.userFromUid[uid] = User.fromSnapshot(uid: uid, snapshot: userSnap);
    }

    // Find me in the user data, and get private info as well
    DataSnapshot privateSnap = await loadChild("${DatabaseConstants.kUSERS_CHILD}/$myUid/${DatabaseConstants.kUSER_PRIVATE_VARS}");
    DataSnapshot publicSnap = await loadChild("${DatabaseConstants.kUSERS_CHILD}/$myUid/${DatabaseConstants.kUSER_PUBLIC_VARS}");
    Database.me = Me.fromSnapshots(uid: myUid, private: privateSnap, public: publicSnap);

    return Database.userFromUid.values.toList();
  }

  // Loads a list of all groups in the database (available to this user)
  static Future<ResponsibleList> loadGroupUids() async {
    DataSnapshot groupsSnap = await loadChild(DatabaseConstants.kGROUPS_LIST_CHILD);
    if (groupsSnap == null){
      print("Error loading group uids");
      return null;
    }

    Database.groupUids = ResponsibleList.fromSnapshot(snapshot: groupsSnap);
    return Database.groupUids;
  }

  // Loads the group data from all available groups
  // Requires the groupUids list to query specific groups
  static Future<List<GroupData>> loadGroups() async {
    // Must have the groupUids list
    if (Database.groupUids == null || Database.groupUids.responsibleList.isEmpty)
      await loadGroupUids();

    Database.groupFromUid = {};

    // Now, query each group to get the data
    for (String groupUid in Database.groupUids.responsibleList.keys){
      String name = await loadGroupName(groupUid);
      if (name == null){
        print("Group $groupUid null name");
        return null;
      }

      ResponsibleList admins = await loadGroupAdmins(groupUid);
      if (admins == null){
        print("Group $groupUid null admins");
        return null;
      }

      ResponsibleList members = await loadGroupMembers(groupUid);
      if (members == null){
        print("Group $groupUid null members");
        return null;
      }

      List<MessageData> messages = await loadGroupMessages(groupUid);
      if (messages == null){
        print("Group $groupUid null messages");
        return null;
      }

      GroupThemeData themeData = await loadGroupThemeData(groupUid);
      if (themeData == null){
        print("Group $groupUid null themeData");
        return null;
      }

      GroupData groupData = GroupData(
          uid: groupUid,
          utcTime: messages[0].utcTime,
          name: name,
          messages: messages,
          admins: admins,
          members: members,
          groupThemeData: themeData
      );

      Database.groupFromUid[groupUid] = groupData;
    }

    return Database.groupFromUid.values.toList();
  }

  // Loads a group name from the uid
  static Future<String> loadGroupName(String groupUid) async {
    DataSnapshot nameSnap = await loadChild("${DatabaseConstants.kGROUPS_CHILD}/$groupUid/${DatabaseConstants.kGROUP_NAME_CHILD}");
    if (nameSnap == null)
      return null;

    return nameSnap.value;
  }

  // Loads all admins from a group as a responsibility list
  static Future<ResponsibleList> loadGroupAdmins(String groupUid) async {
    DataSnapshot adminsSnap = await loadChild("${DatabaseConstants.kGROUPS_CHILD}/$groupUid/${DatabaseConstants.kGROUP_ADMINS_CHILD}");
    if (adminsSnap == null)
      return null;

    return ResponsibleList.fromSnapshot(snapshot: adminsSnap);
  }

  // Loads all members from a group as a responsibility list
  static Future<ResponsibleList> loadGroupMembers(String groupUid) async {
    DataSnapshot membersSnap = await loadChild("${DatabaseConstants.kGROUPS_CHILD}/$groupUid/${DatabaseConstants.kGROUP_MEMBERS_CHILD}");
    if (membersSnap == null)
      return null;

    return ResponsibleList.fromSnapshot(snapshot: membersSnap);
  }

  // Loads all messages from a group as a list of MessageData objects
  // TODO: Load a chunk and stream others
  static Future<List<MessageData>> loadGroupMessages(String groupUid) async {
    DataSnapshot messagesSnap = await loadChild("${DatabaseConstants.kGROUPS_CHILD}/$groupUid/${DatabaseConstants.kGROUP_MESSAGES_CHILD}", true);
    if (messagesSnap == null)
      return null;

    List<MessageData> messages = [];
    for (var messageKey in messagesSnap.value.keys)
      messages.add(MessageData.fromSnapshotValue(message: messagesSnap.value[messageKey], time: messageKey));

    return messages;
  }

  static Future<GroupThemeData> loadGroupThemeData(String groupUid) async {
    DataSnapshot themeSnap = await loadChild("${DatabaseConstants.kGROUPS_CHILD}/$groupUid/${DatabaseConstants.kGROUP_THEME_DATA_CHILD}");
    if (themeSnap == null)
      return null;

    return GroupThemeData.fromSnapshot(snapshot: themeSnap);
  }

  // TODO: Doesn't work yet
  // Note: This must be listened to for the first chunk
  // It will only return one value, and that is the chunk, other data will
  // be streamed to a list
/*
  Future<List<String>> loadUserUids([int chunk = 1]) async {
    print("Getting uids with chunk size $chunk");
    userUids = [];
    Stream<List<Event>> chunkStream = chunkLoad(chunkSize: chunk, location: DatabaseConstants.kUSERS_LIST_CHILD, clearFirst: true);
    chunkStream.listen((List<Event> recChunk){
      print("Rec chunk length: ${recChunk.length}");
      for (Event event in recChunk) {
        String s =  event.snapshot.value.toString();
        print("Adding $s");
        userUids.add(s);
      }
      print("New data done");
    }, onDone: (){
      print("Finished length: ${userUids.length}");
    });
    List<Event> firstEvent = await chunkStream.first;
    List<String> s = [];
    for (Event e in firstEvent)
      s.add(e.snapshot.key);
    print("Returning ${s.toString()}");
    return s;
//    return scrapeSnapshotKeys(await loadFullChild(DatabaseConstants.kUSERS_LIST_CHILD));
  }
*/




  // Loads all the child data of a certain child at once
  static Future<DataSnapshot> loadFullChild([String pathToChild, bool order = false]) async {
    DatabaseReference childRef = Database.database.reference().child(pathToChild);
    DataSnapshot snap;
    if (order)
      snap = await childRef.orderByKey().once();
    snap = await childRef.once();
    return snap;
  }

  // TODO: Doesn't work yet
  // Streams an initial chuck of data to the output stream, then all data once it is loaded
  // Good for preloading massive amounts of data
/*
  Stream<List<Event>> chunkLoad({int chunkSize, String location, bool clearFirst = false}) {
    StreamController<List<Event>> controller;

    Stream<Event> subscription;
    DatabaseReference ref = database.reference().child(location);

    void startSubscription() async {
      subscription = ref.onChildAdded;

      // Take the first chunkSize events and return them
//      List<Event> firstChunk = await subscription.take(chunkSize).toList();
//      controller.add(firstChunk);

      // Just for fun, pause the subscription for a hot second
      print("Im paused");
      Future.delayed(Duration(seconds: 3), (){print("Im back");});

      // Skip the first chunkSize events and get the rest
      List<Event> endChunk = await subscription.skip(chunkSize).toList();

      print("finished getting last");

      // Return either the second chunk or both for the end
      if (clearFirst) {
        controller.add(endChunk);
        print("Adding the end chunk (${endChunk.toString()})");
      } else {
        // Add the end events to the first and return it
  //      for (Event endEvent in endChunk)
  //        firstChunk.add(endEvent);
  //      controller.add(firstChunk);
      }
      controller.close();
    }

    void endSubscription(){
//      subscription.cancel();
      subscription = null;
    }

    controller = new StreamController<List<Event>>.broadcast(
        onListen: startSubscription,
        onCancel: endSubscription
    );

    return controller.stream;
  }
*/

  // Condenses a chunkLoad to two events, the first load and the final load
/*
  Future<List<String>> loadUsers([Function(List<String>) callback, int chunk = 0]) async {
    users = [];
    Stream<List<Event>> stream = chunkLoad(chunk, DatabaseConstants.kUSERS_LIST_CHILD);
//    stream = stream.asBroadcastStream();
//    stream.listen((List<Event> chunked) => chunked.forEach((Event event) => users.add(event.snapshot.value.toString())));
//    List<Event> firstRes = await stream.first;
//    List<String> ret = [];
//    for (Event event in firstRes)
//      ret.add(event.snapshot.value.toString());
//    return ret;
    int c = 0;
    stream.listen((List<Event> chunked){
      List<String> s = [];
      for (Event event in chunked)
        s.add(event.snapshot.value.toString());
      if (c == 0)
        callback(s);
      else
        users = s;
    });
  }
*/

}