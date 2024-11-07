class MyUser {
  final String? uid;
  final String? email;
  final String? displayName;
  final String? fcmToken;
  // final String? photoUrl;
  bool freeUser = false;

  MyUser({this.uid, this.email, this.displayName, this.fcmToken});

  // Factory constructor to create a Project from Firestore document
  factory MyUser.fromFirestore(Map<String, dynamic> data) {
    return MyUser(
      uid: data['userId'] ?? '',
      email: data['email'] ?? '',
      displayName: data['displayName'] ?? '',
      fcmToken: data['fcmToken'] ?? '',
      // Initialize other fields here
    );
  }
}

class Collaborator {
  final String userId; // ID of the collaborator
  final String projectId; // ID of the project they are collaborating on
  final String role; // E.g., 'editor', 'viewer'

  Collaborator({
    required this.userId,
    required this.projectId,
    required this.role,
  });
}
