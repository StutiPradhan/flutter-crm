import 'package:flutter/material.dart';

class CheckOutDialog extends StatefulWidget {
  final Function callback;

  CheckOutDialog({required this.callback});

  @override
  _CheckOutDialogState createState() => _CheckOutDialogState();
}

class _CheckOutDialogState extends State<CheckOutDialog> {
  bool loading = false;

  Future<void> _handleCheckOut() async {
    setState(() {
      loading = true;
    });

    // Execute the asynchronous callback
    await widget.callback();

    setState(() {
      loading = false;
    });

    Navigator.of(context).pop(); // Close the dialog

    // Show a success message
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Checked Out Successfully'),
          content: Text('You have been checked out successfully.'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the success dialog
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Check Out'),
      content: Text('You will be checking out. Proceed?'),
      actions: <Widget>[
        TextButton(
          onPressed: () {
            Navigator.of(context).pop(); // Close the dialog
          },
          child: Text('Cancel'),
        ),
        TextButton(
          onPressed: loading ? null : _handleCheckOut,
          child: Text('Proceed'),
        ),
      ],
    );
  }
}
