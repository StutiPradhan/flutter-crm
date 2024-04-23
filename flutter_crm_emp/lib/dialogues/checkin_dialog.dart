import 'package:flutter/material.dart';

class CheckInDialog extends StatefulWidget {
  final Function callback;

  CheckInDialog({required this.callback});

  @override
  _CheckInDialogState createState() => _CheckInDialogState();
}

class _CheckInDialogState extends State<CheckInDialog> {
  bool loading = false;

  Future<void> _handleCheckIn() async {
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
          title: Text('Checked In Successfully'),
          content: Text('You have been checked in successfully.'),
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
      title: Text('Check In'),
      content: Text('You will be checking in. Proceed?'),
      actions: <Widget>[
        TextButton(
          onPressed: () {
            Navigator.of(context).pop(); // Close the dialog
          },
          child: Text('Cancel'),
        ),
        TextButton(
          onPressed: loading ? null : _handleCheckIn,
          child: Text('Proceed'),
        ),
      ],
    );
  }
}
