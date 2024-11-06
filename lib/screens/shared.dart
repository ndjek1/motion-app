import 'package:flutter/material.dart';

Future<void> showDeleteConfirmationDialog(BuildContext context, Function onDelete) async {
  return showDialog<void>(
    context: context,
    barrierDismissible: false, // Prevent dismissing by tapping outside
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Confirm Delete'),
        content: const Text('Are you sure you want to delete this item?'),
        actions: <Widget>[
          TextButton(
            child: const Text('Cancel'),
            onPressed: () {
              Navigator.of(context).pop(); // Close the dialog
            },
          ),
          TextButton(
            child: const Text('Delete'),
            style: TextButton.styleFrom(
              foregroundColor: Colors.red, // Color for delete button
            ),
            onPressed: () {
              Navigator.of(context).pop(); // Close the dialog
              onDelete(); // Call the onDelete function
            },
          ),
        ],
      );
    },
  );
}
