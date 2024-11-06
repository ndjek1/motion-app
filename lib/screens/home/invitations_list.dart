import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:motion_app/models/project.dart';
import 'package:motion_app/services/database.dart';



// ignore: must_be_immutable
class InvitationListWidget extends StatefulWidget {
  @override
  _InvitationListWidgetState createState() => _InvitationListWidgetState();

  // Firebase user for reference
  User? user = FirebaseAuth.instance.currentUser;

  InvitationListWidget({super.key});
}

class _InvitationListWidgetState extends State<InvitationListWidget> {
  List<Invitation> _invitations = []; // Received invitations
  List<Invitation> _sentInvitations = []; // Sent invitations
  Map<String, String> _senderNames = {}; // To store sender names
  Map<String, String> _receiverNames = {}; // To store receiver names
  List<Map<String, dynamic>> _notifications = []; // Store notification messages

  @override
  void initState() {
    super.initState();
    _loadInvitations();

    // Check if there is any passed message data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final message = ModalRoute.of(context)?.settings.arguments as RemoteMessage?;
      if (message != null) {
        // Extract relevant data from the message and add it to the notifications list
        setState(() {
          _notifications.add({
            'title': message.notification?.title ?? 'No Title',
            'body': message.notification?.body ?? 'No Body',
          });
        });
      }
    });
  }

  Future<void> _loadInvitations() async {
    // Load received and sent invitations (your existing code)
    List<Invitation> invitations = await DatabaseService(uid: widget.user!.uid).loadInvitations();
    List<Invitation> sentInvitations = await DatabaseService(uid: widget.user!.uid).loadSentInvitations();

    // Load sender names (your existing code)
    for (var invitation in invitations) {
      String? senderName = await DatabaseService(uid: widget.user!.uid).getUserNameById(invitation.senderId);
      if (senderName != null) {
        _senderNames[invitation.senderId] = senderName;
      }
    }

    // Load receiver names (your existing code)
    for (var sentInvitation in sentInvitations) {
      String? receiverName = await DatabaseService(uid: widget.user!.uid).getUserNameById(sentInvitation.receiverId);
      if (receiverName != null) {
        _receiverNames[sentInvitation.receiverId] = receiverName;
      }
    }

    setState(() {
      _invitations = invitations;
      _sentInvitations = sentInvitations;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Invitations'),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Display Notification Messages
            if (_notifications.isNotEmpty) ...[
              const Padding(
                padding: EdgeInsets.all(8.0),
                child: Text(
                  'Notifications',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _notifications.length,
                itemBuilder: (context, index) {
                  final notification = _notifications[index];
                  return ListTile(
                    title: Text(notification['title']),
                    subtitle: Text(notification['body']),
                  );
                },
              ),
            ],
            // Received Invitations
            if (_invitations.isNotEmpty) ...[
              const Padding(
                padding: EdgeInsets.all(8.0),
                child: Text(
                  'Received Invitations',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _invitations.length,
                itemBuilder: (context, index) {
                  Invitation invitation = _invitations[index];
                  String senderName = _senderNames[invitation.senderId] ?? 'Unknown';

                  return ListTile(
                    title: Text(invitation.projectName),
                    subtitle: Text('Sent by: $senderName, Date: ${invitation.sentAt}'),
                    trailing: invitation.isAccepted
                        ? const Text(
                            'Accepted',
                            style: TextStyle(color: Colors.green),
                          )
                        : TextButton(
                            onPressed: () async {
                              await DatabaseService(uid: widget.user!.uid).acceptInvitation(invitation.id, invitation.projectId);
                              setState(() {
                                invitation.isAccepted = true;
                              });
                            },
                            child: const Text('Accept'),
                          ),
                  );
                },
              ),
            ],
            // Sent Invitations
            if (_sentInvitations.isNotEmpty) ...[
              const Padding(
                padding: EdgeInsets.all(8.0),
                child: Text(
                  'Sent Invitations',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _sentInvitations.length,
                itemBuilder: (context, index) {
                  Invitation sentInvitation = _sentInvitations[index];
                  String receiverName = _receiverNames[sentInvitation.receiverId] ?? 'Unknown';

                  return ListTile(
                    title: Text(sentInvitation.projectName),
                    subtitle: Text('Sent to: $receiverName, Date: ${sentInvitation.sentAt}'),
                    trailing: sentInvitation.isAccepted
                        ? const Text(
                            'Accepted',
                            style: TextStyle(color: Colors.green),
                          )
                        : const Text('Pending'),
                  );
                },
              ),
            ],
          ],
        ),
      ),
    );
  }
}
