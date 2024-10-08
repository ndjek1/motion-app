import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:motion_app/models/project.dart';


class DatabaseService {
  final String? uid;

  DatabaseService({this.uid});

  final CollectionReference userCollection =
      FirebaseFirestore.instance.collection("users");
  final CollectionReference projectCollection =
      FirebaseFirestore.instance.collection("projects");
  final CollectionReference invitationsCollection =
      FirebaseFirestore.instance.collection("invitations");

  Future<void> updateUserData(String? uid, String? email, String? displayName,
      String? isFreeUser) async {
    if (uid != null) {
      await userCollection.doc(uid).set({
        'userId': uid,
        'email': email,
        'displayName': displayName,
        'isFreeUser': 'false',
      });
    } else {
      throw Exception("User ID cannot be null");
    }
  }

  Future<void> updateProjectData(
      String? uid,
      String title,
      String description,
      String? ownerId,
      String? createdAt,
      String? updatedAt,
      List<String>? collaboratorIds,
      List<Task>? tasks) async {
    if (uid != null) {
      await projectCollection.doc(uid).set({
        'projectId': uid,
        'title': title,
        'description': description,
        'ownerId': ownerId,
        'createdAt': createdAt,
        'updatedAt': updatedAt,
        'collaboratorIds': collaboratorIds,
        'tasks': tasks,
      });
    } else {
      throw Exception("User ID cannot be null");
    }
  }

  Future<bool> isFreeUser(String uid) async {
    try {
      DocumentSnapshot userDoc = await userCollection.doc(uid).get();
      if (userDoc.exists) {
        // Assuming isFreeUser is stored as a string ("true" or "false")
        String isFreeUserString = userDoc['isFreeUser'] ?? 'false';
        // Check if isFreeUserString is equal to "true"
        return isFreeUserString.toLowerCase() == 'true';
      } else {
        throw Exception("User not found");
      }
    } catch (e) {
      print('Error fetching user data: $e');
      return false;
    }
  }

  Future<List<Project>> getUserProjects(String currentUserId) async {
    try {
      // Reference to the projects collection

      // Query to get projects where ownerId matches the current user ID
      QuerySnapshot querySnapshot = await projectCollection
          .where('ownerId', isEqualTo: currentUserId)
          .get();

      // Convert the documents to a list of Project objects
      List<Project> userProjects = querySnapshot.docs.map((doc) {
        return Project.fromFirestore(doc.data() as Map<String, dynamic>);
      }).toList();
      print(" project id ${userProjects[0].id} ");

      return userProjects;
    } catch (e) {
      print('Error fetching user projects: $e');
      return [];
    }
  }

  // send invitation for other users to join the project

  // Send an invitation to another user
  Future<void> sendInvitation(
      String projectId, String projectName, String receiverId) async {
    try {
      final String invitationId =
          DateTime.now().millisecondsSinceEpoch.toString();
      Invitation newInvitation = Invitation(
        id: invitationId,
        projectId: projectId,
        senderId: uid!,
        receiverId: receiverId,
        projectName: projectName,
        sentAt: DateTime.now(),
      );
      await invitationsCollection.doc(invitationId).set(newInvitation.toMap());
    } catch (e) {
      print('Error sending invitation: $e');
      throw Exception('Failed to send invitation');
    }
  }

  // Accept an invitation
  Future<void> acceptInvitation(String invitationId, String projectId) async {
    try {
      // Get the invitation document
      DocumentSnapshot invitationDoc =
          await invitationsCollection.doc(invitationId).get();
      if (invitationDoc.exists) {
        await invitationsCollection
            .doc(invitationId)
            .update({'isAccepted': true});

        // Add the user to the project as a collaborator
        await projectCollection.doc(projectId).update({
          'collaboratorIds': FieldValue.arrayUnion([uid]),
        });
      } else {
        throw Exception('Invitation not found');
      }
    } catch (e) {
      print('Error accepting invitation: $e');
      throw Exception('Failed to accept invitation');
    }
  }

  // Load invitations for a specific user
  Future<List<Invitation>> loadInvitations() async {
    try {
      QuerySnapshot querySnapshot =
          await invitationsCollection.where('receiverId', isEqualTo: uid).get();

      return querySnapshot.docs
          .map((doc) => Invitation.fromMap(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('Error loading invitations: $e');
      return [];
    }
  }

  // Load invitations for a specific user
  Future<List<Invitation>> loadSentInvitations() async {
    try {
      QuerySnapshot querySnapshot =
          await invitationsCollection.where('senderId', isEqualTo: uid).get();

      return querySnapshot.docs
          .map((doc) => Invitation.fromMap(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('Error loading invitations: $e');
      return [];
    }
  }

  Future<String?> getUserIdByEmail(String email) async {
    try {
      QuerySnapshot querySnapshot =
          await userCollection.where('email', isEqualTo: email).limit(1).get();

      if (querySnapshot.docs.isNotEmpty) {
        return querySnapshot.docs.first['userId'];
      } else {
        throw Exception("No user found with this email.");
      }
    } catch (e) {
      print('Error fetching UID by email: $e');
      return null;
    }
  }

  Future<String?> getUserNameById(String uid) async {
    try {
      QuerySnapshot querySnapshot =
          await userCollection.where('userId', isEqualTo: uid).limit(1).get();

      if (querySnapshot.docs.isNotEmpty) {
        return querySnapshot.docs.first['displayName'];
      } else {
        throw Exception("No user found with this uid.");
      }
    } catch (e) {
      print('Error fetching usename by uid: $e');
      return null;
    }
  }
}
