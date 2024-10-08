import 'package:firebase_auth/firebase_auth.dart';
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

  @override
  void initState() {
    super.initState();
    _loadInvitations();
  }

  Future<void> _loadInvitations() async {
    // Load received and sent invitations
    List<Invitation> invitations =
        await DatabaseService(uid: widget.user!.uid).loadInvitations();
    List<Invitation> sentInvitations =
        await DatabaseService(uid: widget.user!.uid).loadSentInvitations();

    // Load sender names
    for (var invitation in invitations) {
      String? senderName = await DatabaseService(uid: widget.user!.uid)
          .getUserNameById(invitation.senderId);
      print(senderName);
      if (senderName != null) {
        _senderNames[invitation.senderId] = senderName;
      }
    }

    // Load receiver names
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
      ),
      body: _invitations.isEmpty && _sentInvitations.isEmpty
          ? const Center(child: Text('No invitations yet.'))
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (_invitations.isNotEmpty) ...[
                    const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text(
                        'Received Invitations',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _invitations.length,
                      itemBuilder: (context, index) {
                        Invitation invitation = _invitations[index];
                        String senderName =
                            _senderNames[invitation.senderId] ?? 'Unknown';

                        return ListTile(
                          title: Text(invitation.projectName),
                          subtitle: Text(
                              'Sent by: $senderName, Date: ${invitation.sentAt}'),
                          trailing: invitation.isAccepted
                              ? const Text(
                                  'Accepted',
                                  style: TextStyle(color: Colors.green),
                                )
                              : TextButton(
                                  onPressed: () async {
                                    await DatabaseService(uid: widget.user!.uid)
                                        .acceptInvitation(invitation.id,
                                            invitation.projectId);
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
                  if (_sentInvitations.isNotEmpty) ...[
                    const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text(
                        'Sent Invitations',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _sentInvitations.length,
                      itemBuilder: (context, index) {
                        Invitation sentInvitation = _sentInvitations[index];
                        String receiverName =
                            _receiverNames[sentInvitation.receiverId] ??
                                'Unknown';

                        return ListTile(
                          title: Text(sentInvitation.projectName),
                          subtitle: Text(
                              'Sent to: $receiverName, Date: ${sentInvitation.sentAt}'),
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
