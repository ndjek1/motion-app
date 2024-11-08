import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:motion_app/models/project.dart';
import 'package:motion_app/services/database.dart';

// ignore: must_be_immutable
class InvitationListWidget extends StatefulWidget {
  @override
  // ignore: library_private_types_in_public_api
  _InvitationListWidgetState createState() => _InvitationListWidgetState();

  User? user = FirebaseAuth.instance.currentUser;

  InvitationListWidget({super.key});
}

class _InvitationListWidgetState extends State<InvitationListWidget> {
  List<Invitation> _invitations = [];
  List<Invitation> _sentInvitations = [];
  final Map<String, String> _senderNames = {};
  final Map<String, String> _receiverNames = {};
  final List<Map<String, dynamic>> _notifications = [];

  @override
  void initState() {
    super.initState();
    _loadInvitations();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final message =
          ModalRoute.of(context)?.settings.arguments as RemoteMessage?;
      if (message != null) {
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
    List<Invitation> invitations =
        await DatabaseService(uid: widget.user!.uid).loadInvitations();
    List<Invitation> sentInvitations =
        await DatabaseService(uid: widget.user!.uid).loadSentInvitations();
    for (var invitation in invitations) {
      String? senderName = await DatabaseService(uid: widget.user!.uid)
          .getUserNameById(invitation.senderId);
      if (senderName != null) {
        _senderNames[invitation.senderId] = senderName;
      }
    }
    for (var sentInvitation in sentInvitations) {
      String? receiverName = await DatabaseService(uid: widget.user!.uid)
          .getUserNameById(sentInvitation.receiverId);
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
        backgroundColor: Colors.grey[800],
        foregroundColor: Colors.white,
      ),
      body: Container(
        color: Colors.grey[200],
        padding: const EdgeInsets.all(12.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (_notifications.isNotEmpty) ...[
                const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text(
                    'Notifications',
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.indigo),
                  ),
                ),
                _buildNotificationList(),
              ],
              if (_invitations.isNotEmpty) ...[
                const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text(
                    'Received Invitations',
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.indigo),
                  ),
                ),
                _buildInvitationList(_invitations, _senderNames, true),
              ],
              if (_sentInvitations.isNotEmpty) ...[
                const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text(
                    'Sent Invitations',
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.indigo),
                  ),
                ),
                _buildInvitationList(_sentInvitations, _receiverNames, false),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNotificationList() {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _notifications.length,
      itemBuilder: (context, index) {
        final notification = _notifications[index];
        return Card(
          elevation: 2,
          margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
          color: Colors.white,
          child: ListTile(
            title: Text(
              notification['title'],
              style: const TextStyle(
                  fontWeight: FontWeight.bold, color: Colors.indigo),
            ),
            subtitle: Text(notification['body']),
          ),
        );
      },
    );
  }

  Widget _buildInvitationList(List<Invitation> invitations,
      Map<String, String> names, bool isReceived) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: invitations.length,
      itemBuilder: (context, index) {
        Invitation invitation = invitations[index];
        String displayName =
            names[isReceived ? invitation.senderId : invitation.receiverId] ??
                'Unknown';

        return Card(
          elevation: 2,
          margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
          child: ListTile(
            title: Text(
              invitation.projectName,
              style: const TextStyle(
                  fontWeight: FontWeight.bold, color: Colors.black87),
            ),
            subtitle: Text(
              '${isReceived ? 'Sent by' : 'Sent to'}: $displayName\nDate: ${invitation.sentAt}',
              style: const TextStyle(color: Colors.grey),
            ),
            trailing: invitation.isAccepted
                ? const Text(
                    'Accepted',
                    style: TextStyle(
                        color: Colors.green, fontWeight: FontWeight.bold),
                  )
                : isReceived
                    ? ElevatedButton(
                        onPressed: () async {
                          await DatabaseService(uid: widget.user!.uid)
                              .acceptInvitation(
                                  invitation.id, invitation.projectId);
                          setState(() {
                            invitation.isAccepted = true;
                          });
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.indigo,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Accept',
                          style: TextStyle(color: Colors.white),
                        ),
                      )
                    : const Text(
                        'Pending',
                        style: TextStyle(
                            color: Colors.orange, fontWeight: FontWeight.bold),
                      ),
          ),
        );
      },
    );
  }
}
