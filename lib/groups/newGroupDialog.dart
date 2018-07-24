import 'package:flutter/material.dart';
import 'groupsListItem.dart';

class NewGroupDialog extends StatefulWidget {
  final Map<String, GlobalKey<GroupsListItemState>> groups;
  final Function addNewGroup;

  const NewGroupDialog({this.groups, this.addNewGroup});

  @override
  State createState() => new NewGroupDialogState(groups: groups, addNewGroup: addNewGroup);
}

class NewGroupDialogState extends State<NewGroupDialog> {
  bool canSub = false;
  String groupName;
  final Map<String, GlobalKey<GroupsListItemState>> groups;
  final Function addNewGroup;

  NewGroupDialogState({this.groups, this.addNewGroup});

  Widget build(BuildContext context) {
    return new AlertDialog(
      title: new Text("Add New Group"),
      content: new TextField(
        decoration: new InputDecoration(
          labelText: "Group Name",
          isDense: true,
        ),
        onChanged: (String text){
          groupName = text;
          setState(() {
            canSub = groupName.length > 0 && !groups.containsKey(groupName);
          });
        }
      ),

      actions: <Widget>[
        new FlatButton(
          child: new Text("Cancel"),
          onPressed: () => Navigator.pop(context),
        ),

        new FlatButton(
          child: new Text("Add"),
          onPressed: canSub ? () => internalAddNewGroup(context) : null,
        )
      ],
    );
  }

  void internalAddNewGroup(BuildContext context){
    Navigator.pop(context);
    addNewGroup(groupName);
  }
}