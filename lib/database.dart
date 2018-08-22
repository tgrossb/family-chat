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

class DatabaseWriter {
  static final FirebaseDatabase database = FirebaseDatabase.instance;

  static void registerNewUser({@required Me me}) async {
    database.reference().child("$kUSERS_CHILD").set(me.toDatabaseChild());
    database.reference().child("$kUSERS_LIST_CHILD").set({me.uid: "uid"});
  }

  // They must be a registered user as well, verified by database rules
  static void registerNewSudoer({@required User user}) async {
    database.reference().child(kSUDOERS_CHILD).set({user.uid: "uid"});
  }

  static void registerNewGroup({@required Me me, @required List<User> admins, @required List<User> members, @required String groupName}) async {
    if (!admins.contains(me))
      admins.add(me);
    if (!members.contains(me))
      members.add(me);

    Map adminsMap = {};
    for (User admin in admins)
      adminsMap[admin.uid] = "uid";

    Map membersMap = {};
    for (User member in members)
      membersMap[member.uid] = "uid";

    Map group = {
      groupName: {
        kADMINS_CHILD: adminsMap,
        kMEMBERS_CHILD: membersMap,
        kMESSAGES_CHILD: {
          Utils.timeToKeyString(DateTime.now()): {
            kNAME_CHILD: "System",
            kTEXT_CHILD: "${me.name} created the group $groupName"
          }
        }
      }
    };

    database.reference().child(kGROUPS_CHILD).set(group);
    database.reference().child(kGROUPS_LIST_CHILD).set({groupName: "group"});
  }

  static void addMessage({@required String groupName, @required MessageData message}) async {
    database.reference().child("$kGROUPS_CHILD/$groupName/$kMESSAGES_CHILD").set(
      {
        Utils.timeToKeyString(message.utcTime): {
          kNAME_CHILD: message.name,
          kTEXT_CHILD: message.text
        }
      });
  }
}

class DatabaseReader {
  static final FirebaseDatabase database = FirebaseDatabase.instance;

  static List<String> sudoerUids;
  static List<String> userUids;
  static List<User> users;
  static User me;
  static List<String> groupNames;

  // Loads a list of all sudoers' uids in the database
  // TODO: I don't **think** we need this
  static Future<List<String>> loadSudoerUids() async {
    DataSnapshot sudoersSnap = await loadFullChild(kSUDOERS_CHILD);
    print("Loading sudoers, snapped value: " + sudoersSnap.value.toString() + ", snapped key: " + sudoersSnap.key.toString());

    sudoerUids = scrapeSnapshotKeys(sudoersSnap);
    return sudoerUids;
  }

  // Loads a list of all users in the database without their data
  static Future<List<String>> loadUserUids() async {
    DataSnapshot usersSnap = await loadFullChild(kUSERS_LIST_CHILD);
    userUids = scrapeSnapshotKeys(usersSnap);
    return userUids;
  }

  // Loads all of the public data of all users in the database
  static Future<List<User>> loadUsers(String myUid) async {
    // We have to query specific uids because of the database rules, so make sure they have been loaded
    if (userUids == null || userUids.length == 0)
      loadUserUids();

    users = [];

    for (String uid in userUids) {
      // If the uid is me, don't add it
      // We'll handle my data later
      if (uid == myUid)
        continue;

      // Query the public data of each user
      // Access is denied to private data, so this is not the only defense
      DataSnapshot userSnap = await loadFullChild("$kUSERS_CHILD/$uid/$kUSER_PUBLIC_VARS");

      // Convert each user to a User object and add it to the list
      users.add(User.fromSnapshot(uid: uid, snapshot: userSnap));
    }

    // Find me in the user data, and get private info as well
    DataSnapshot meSnap = await loadFullChild("$kUSERS_CHILD/$myUid");
    me = Me.fromSnapshot(snapshot: meSnap);

    return users;
  }

  // Loads a list of all groups in the database
  static Future<List<String>> loadGroupNames() async {
    DataSnapshot groupsSnap = await loadFullChild(kGROUPS_LIST_CHILD);

    groupNames = scrapeSnapshotKeys(groupsSnap);
    return groupNames;
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
  static Future<DataSnapshot> loadFullChild(String pathToChild) async {
    DatabaseReference childRef = database.reference().child(pathToChild);
    DataSnapshot snap = await childRef.once();
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