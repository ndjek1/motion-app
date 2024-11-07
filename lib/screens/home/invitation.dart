import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:motion_app/services/database.dart';

// ignore: must_be_immutable
class SendInvitationWidget extends StatelessWidget {
  final String projectId;
  final String projectName;
  User? user = FirebaseAuth.instance.currentUser;

  SendInvitationWidget({required this.projectId, required this.projectName});

  final TextEditingController _receiverController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Send Invitation'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _receiverController,
            decoration: InputDecoration(labelText: 'Receiver User email'),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () async {
            String? receiverId = await DatabaseService(uid: user!.uid)
                .getUserIdByEmail(_receiverController.text.trim());
            if (receiverId!.isNotEmpty) {
              try {
                await DatabaseService(uid: user!.uid)
                    .sendInvitation(projectId, projectName, receiverId);
                Navigator.pop(context);
                print('Invitation sent to $receiverId');
              } catch (e) {
                print('Error: $e');
              }
            }
          },
          child: Text('Send'),
        ),
        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: Text('Cancel'),
        ),
      ],
    );
  }
}
