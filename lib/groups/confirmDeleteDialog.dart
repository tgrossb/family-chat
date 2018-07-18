import 'package:flutter/material.dart';
import 'groupsListItem.dart';

class ConfirmDeleteDialog extends StatefulWidget {
  final GroupsListItem group;
  final Function deleteGroup;

  const ConfirmDeleteDialog({this.group, this.deleteGroup});

  @override
  State createState() => new ConfirmDeleteDialogState(group: group, deleteGroup: deleteGroup);
}

class ConfirmDeleteDialogState extends State<ConfirmDeleteDialog> {
  final GroupsListItem group;
  final Function deleteGroup;

  ConfirmDeleteDialogState({this.group, this.deleteGroup});

  Widget build(BuildContext context) {
    return new AlertDialog(
      title: new Text("You are about to delete the group '" + group.name + "'"),
      content: new RichText(
        text: new TextSpan(
          // Note: Styles for TextSpans must be explicitly defined.
          // Child text spans will inherit styles from parent
          style: Theme.of(context).primaryTextTheme.subhead,
          children: <TextSpan>[
            new TextSpan(text: "Deleting this group will delete all messages stored here "),
            new TextSpan(text: "perminantly.", style: new TextStyle(fontWeight: FontWeight.bold)),
            new TextSpan(text: "\nAre you sure you want to continue?")
          ],
        ),
      ),

      //new Text("Deleting this group will delete all messages stored here ")

      actions: <Widget>[
        new FlatButton(
          child: new Text("Cancel"),
          onPressed: () => Navigator.pop(context),
        ),

        new FlatButton(
          child: new Text("Continue"),
          onPressed: () => internalDeleteGroup(context),
        )
      ],
    );
  }

  void internalDeleteGroup(BuildContext context){
    Navigator.pop(context);
    deleteGroup(group);
  }
}