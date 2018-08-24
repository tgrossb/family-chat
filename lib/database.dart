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
import 'package:bodt_chat/user.dart';
import 'package:bodt_chat/dataBundles.dart';

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

  static List<String> sudoerUids;
  static List<String> userUids;
  static Map<String, User> userFromUid;
  static User me;
  static List<String> groupNames;
  static Map<String, GroupData> groupFromName;

//  get groups => groupFromName.values;
//  get users => userFromUid.values;
}

class DatabaseWriter {
  static void registerNewUser({@required Me me}) async {
    Database.database.reference().child("$kUSERS_CHILD").set(me.toDatabaseChild());
    Database.database.reference().child("$kUSERS_LIST_CHILD").set({me.uid: "uid"});

    // Update the database class to reflect this change
    Database.userUids.add(me.uid);
    Database.userFromUid[me.uid] = me;
  }

  // They must be a registered user as well, verified by database rules
  static void registerNewSudoer({@required User user}) async {
    Database.database.reference().child(kSUDOERS_CHILD).set({user.uid: "uid"});

    // Update the database class to reflect this change
    Database.sudoerUids.add(user.uid);
  }

  static void registerNewGroup({@required List<String> admins, @required List<String> members, @required String groupName}) async {
    if (!admins.contains(Database.me.uid))
      admins.add(Database.me.uid);
    if (!members.contains(Database.me))
      members.add(Database.me.uid);

    Map adminsMap = {};
    for (String adminUid in admins)
      adminsMap[adminUid] = "uid";

    Map membersMap = {};
    for (String memberUid in members)
      membersMap[memberUid] = "uid";

    Map group = {
      groupName: {
        kADMINS_CHILD: adminsMap,
        kMEMBERS_CHILD: membersMap,
        kMESSAGES_CHILD: {
          Utils.timeToKeyString(DateTime.now()): {
            kNAME_CHILD: "System",
            kTEXT_CHILD: "${Database.me.name} created the group $groupName"
          }
        }
      }
    };

    Database.database.reference().child(kGROUPS_CHILD).set(group);
    Database.database.reference().child(kGROUPS_LIST_CHILD).set({groupName: "group"});

    // Update the database class to reflect this change
    DateTime utcTime = group[groupName][kMESSAGES_CHILD].keys[0];
    GroupData groupData = GroupData(
        utcTime: utcTime,
        name: groupName,
        firstMessages: [MessageData.fromSnapshotValue(message: group[groupName][kMESSAGES_CHILD][utcTime])],
        admins: admins,
        members: members
    );

    Database.groupNames.add(groupName);
    Database.groupFromName[groupName] = groupData;
  }

  static void removeGroup(String groupName){
    Database.database.reference().child("$kGROUPS_CHILD/$groupName").remove();

    // Update the database class to reflect this change
    Database.groupNames.remove(groupName);
    Database.groupFromName.removeWhere((String name, GroupData data) => name == groupName);
  }

  static void addMessage({@required String groupName, @required MessageData message}) async {
    Database.database.reference().child("$kGROUPS_CHILD/$groupName/$kMESSAGES_CHILD").set(
      {
        Utils.timeToKeyString(message.utcTime): {
          kNAME_CHILD: message.name,
          kTEXT_CHILD: message.text
        }
      });

    // Update the database class to reflect this change
    Database.groupFromName[groupName].firstMessages.insert(0, message);
  }
}

class DatabaseReader {
  // Checks if a user exists by querying a test child
  // This will cause an error if the user doesn't exist
  static Future<bool> userExists() async {
    try {
      await loadFullChild(kUSER_EXISTS_TEST);
    } catch (e){
      if (e is DatabaseError) {
        print("User doesn't exist");
        print(e.message);

        return false;
      }
    }
    return true;
  }

  // Loads a list of all sudoers' uids in the database
  // TODO: I don't **think** we need this
  static Future<List<String>> loadSudoerUids() async {
    DataSnapshot sudoersSnap = await loadFullChild(kSUDOERS_CHILD);
    print("Loading sudoers, snapped value: " + sudoersSnap.value.toString() + ", snapped key: " + sudoersSnap.key.toString());

    Database.sudoerUids = scrapeSnapshotKeys(sudoersSnap);
    return Database.sudoerUids;
  }

  // Loads a list of all users in the database without their data
  static Future<List<String>> loadUserUids() async {
    DataSnapshot usersSnap = await loadFullChild(kUSERS_LIST_CHILD);
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
      DataSnapshot userSnap = await loadFullChild("$kUSERS_CHILD/$uid/$kUSER_PUBLIC_VARS");

      // Convert each user to a User object and add it to the map
      Database.userFromUid[uid] = User.fromSnapshot(uid: uid, snapshot: userSnap);
    }

    // Find me in the user data, and get private info as well
    DataSnapshot meSnap = await loadFullChild("$kUSERS_CHILD/$myUid");
    Database.me = Me.fromSnapshot(snapshot: meSnap);

    return Database.userFromUid.values;
  }

  // Loads a list of all groups in the database (available to this user)
  static Future<List<String>> loadGroupNames() async {
    DataSnapshot groupsSnap = await loadFullChild(kGROUPS_LIST_CHILD);

    Database.groupNames = scrapeSnapshotKeys(groupsSnap);
    return Database.groupNames;
  }

  // Loads the group data from all available groups
  // Requires the groupNames list to query specific groups
  static Future<List<GroupData>> loadGroups() async {
    // Must have the groupsNames list
    if (Database.groupNames == null || Database.groupNames.length == 0)
      await loadGroupNames();

    Database.groupFromName = {};

    // Now, query each group to get the data
    for (String groupName in Database.groupNames){
      List<String> admins = await loadAdmins(groupName);
      List<String> members = await loadMembers(groupName);

      List<MessageData> messages = await loadMessages(groupName);

      GroupData groupData = GroupData(
          utcTime: messages[0].utcTime,
          name: groupName,
          firstMessages: messages,
          admins: admins,
          members: members
      );

      Database.groupFromName[groupName] = groupData;
    }

    return Database.groupFromName.values;
  }

  // Loads all admins from a group as a list of uids
  static Future<List<String>> loadAdmins(String groupName) async {
    DataSnapshot adminsSnap = await loadFullChild("$kGROUPS_CHILD/$groupName/$kADMINS_CHILD");
    return scrapeSnapshotKeys(adminsSnap);
  }

  // Loads all members from a group as a list of uids
  static Future<List<String>> loadMembers(String groupName) async {
    DataSnapshot membersSnap = await loadFullChild("$kGROUPS_CHILD/$groupName/$kMEMBERS_CHILD");
    return scrapeSnapshotKeys(membersSnap);
  }

  // Loads all messages from a group as a list of MessageData objects
  // TODO: Load a chunk and stream others
  static Future<List<MessageData>> loadMessages(String groupName) async {
    DataSnapshot messagesSnap = await loadFullChild("$kGROUPS_CHILD/$groupName/$kMESSAGES_CHILD", true);

    List<MessageData> messages = [];
    for (var messageKey in messagesSnap.value.keys)
      messages.add(MessageData.fromSnapshotValue(message: messagesSnap.value[messageKey]));

    return messages;
  }

  // TODO: Doesn't work yet
  // Note: This must be listened to for the first chunk
  // It will only return one value, and that is the chunk, other data will
  // be streamed to a list
/*
  Future<List<String>> loadUserUids([int chunk = 1]) async {
    print("Getting uids with chunk size $chunk");
    userUids = [];
    Stream<List<Event>> chunkStream = chunkLoad(chunkSize: chunk, location: kUSERS_LIST_CHILD, clearFirst: true);
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
//    return scrapeSnapshotKeys(await loadFullChild(kUSERS_LIST_CHILD));
  }
*/

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
    Stream<List<Event>> stream = chunkLoad(chunk, kUSERS_LIST_CHILD);
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