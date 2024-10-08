class MyUser {
  final String? uid;
  final String? email;
  final String? displayName;
  // final String? photoUrl;
  bool freeUser = false;

  MyUser({this.uid, this.email, this.displayName});
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
