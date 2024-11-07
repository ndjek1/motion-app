import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:motion_app/services/database.dart';

class SendInvitationWidget extends StatefulWidget {
  final String projectId;
  final String projectName;

  SendInvitationWidget({required this.projectId, required this.projectName});

  @override
  _SendInvitationWidgetState createState() => _SendInvitationWidgetState();
}

class _SendInvitationWidgetState extends State<SendInvitationWidget> {
  User? user = FirebaseAuth.instance.currentUser;
  final TextEditingController _receiverController = TextEditingController();
  List<String> _suggestedEmails = [];

  @override
  void initState() {
    super.initState();
    _receiverController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _receiverController.removeListener(_onSearchChanged);
    _receiverController.dispose();
    super.dispose();
  }

  void _onSearchChanged() async {
    if (_receiverController.text.isNotEmpty) {
      // Fetch matching emails from the database as the user types
      List<String> suggestions = await DatabaseService(uid: user!.uid)
          .getMatchingUserEmails(_receiverController.text.trim());
      setState(() {
        _suggestedEmails = suggestions;
      });
    } else {
      setState(() {
        _suggestedEmails.clear();
      });
    }
  }

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
          // Display email suggestions
          if (_suggestedEmails.isNotEmpty)
            ListView.builder(
              shrinkWrap: true,
              itemCount: _suggestedEmails.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(_suggestedEmails[index]),
                  onTap: () {
                    _receiverController.text = _suggestedEmails[index];
                    setState(() {
                      _suggestedEmails.clear();
                    });
                  },
                );
              },
            ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () async {
            String? receiverId = await DatabaseService(uid: user!.uid)
                .getUserIdByEmail(_receiverController.text.trim());
            if (receiverId != null && receiverId.isNotEmpty) {
              try {
                await DatabaseService(uid: user!.uid).sendInvitation(
                    widget.projectId, widget.projectName, receiverId);
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
