import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class SetNameDialog extends StatefulWidget {
  final Function(String) onNameSet;

  const SetNameDialog({super.key, required this.onNameSet});

  @override
  State<SetNameDialog> createState() => _SetNameDialogState();
}

class _SetNameDialogState extends State<SetNameDialog> {
  var _nameController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text("Drawing Name"),
      content: SizedBox(
        width: 400,
        child: TextField(
          controller: _nameController,
          minLines: 1,
          maxLines: 1,
          decoration: InputDecoration(
            border: OutlineInputBorder(),
            suffixIcon: Padding(
              padding: EdgeInsets.all(4.0),
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: Text("Cancel"),
        ),
        TextButton(
          onPressed: () {
            if (_nameController.text.trim().isNotEmpty) {
              Navigator.pop(context);
              widget.onNameSet(_nameController.text);
            }
          },
          child: Text("Ok"),
        ),
      ],
    );
  }
}