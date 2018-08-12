import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

class GroupsListData {
  FirebaseUser user;
  List<GroupData> groupsData;
  GroupsListData({@required this.user, @required this.groupsData});
}