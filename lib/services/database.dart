import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:motion_app/models/project.dart';
import 'package:motion_app/models/user.dart';

class DatabaseService {
  final String? uid;

  DatabaseService({this.uid});

  final CollectionReference userCollection =
      FirebaseFirestore.instance.collection("users");
  final CollectionReference projectCollection =
      FirebaseFirestore.instance.collection("projects");
  final CollectionReference invitationsCollection =
      FirebaseFirestore.instance.collection("invitations");
  final CollectionReference tasksCollection =
      FirebaseFirestore.instance.collection("tasks");
  final CollectionReference commentsCollection =
      FirebaseFirestore.instance.collection("comments");

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

  Future<void> updateTaskData(
    String? id,
    String title,
    String description,
    String? projectId,
    String? assignedTo,
    String? status,
    DateTime createdAt,
    DateTime dueDate,
  ) async {
    if (id != null) {
      await tasksCollection.doc(id).set({
        'taskId': id,
        'title': title,
        'description': description,
        'projectId': projectId,
        'assignedTo': assignedTo,
        'createdAt': createdAt,
        'status': status,
        'dueDate': dueDate,
      });
      print('Task added');
    } else {
      throw Exception("task  ID cannot be null");
    }
  }

  Future<void> updateProjectComments(
    String? id,
    String content,
    String userId,
    String? projectId,
    DateTime createdAt,
  ) async {
    if (id != null) {
      await commentsCollection.doc(id).set({
        'id': id,
        'content': content,
        'userId': userId,
        'projectId': projectId,
        'createdAt': createdAt,
      });
      print('Comment added');
    } else {
      throw Exception("task  ID cannot be null");
    }
  }

  // Fetch comments related to a project and return them in reverse order
  Stream<List<Comment>> getProjectComments(String projectId) {
    Stream<List<Comment>> comments = commentsCollection
        .where('projectId', isEqualTo: projectId)
        .orderBy('createdAt', descending: true) // Fetch in descending order
        .snapshots()
        .map((snapshot) {
      // Reverse the list and convert it back to List<Comment>
      return snapshot.docs
          .map((doc) {
            return Comment.fromFirestore(doc.data() as Map<String, dynamic>);
          })
          .toList()
          .reversed
          .toList(); // Reverse and convert to list
    });

    return comments;
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

  Future<List<Project>> getUserInvitedProjects(String currentUserId) async {
    try {
      QuerySnapshot querySnapshot = await projectCollection
          .where('collaboratorIds', arrayContains: currentUserId)
          .get();

      List<Project> invitedProjects = querySnapshot.docs.map((doc) {
        return Project.fromFirestore(doc.data() as Map<String, dynamic>);
      }).toList();

      return invitedProjects;
    } catch (e) {
      print('Error fetching invited projects: $e');
      return [];
    }
  }

  Stream<List<Project>> getProjectStream(String uid) {
    return projectCollection
        .where('ownerId',
            isEqualTo: uid) // Assuming you're filtering by the user
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) =>
                Project.fromFirestore(doc.data() as Map<String, dynamic>))
            .toList());
  }

  Stream<List<Task>> getTasksStream(String pid) {
    return tasksCollection
        .where('projectId',
            isEqualTo: pid) // Assuming you're filtering by the user
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map(
                (doc) => Task.fromFirestore(doc.data() as Map<String, dynamic>))
            .toList());
  }

  Future<List<Task>> getProjectTasks(String projectId) async {
    try {
      // Reference to the projects collection

      // Query to get projects where ownerId matches the current user ID
      QuerySnapshot querySnapshot =
          await tasksCollection.where('projectId', isEqualTo: projectId).get();

      // Convert the documents to a list of Project objects
      List<Task> projectTasks = querySnapshot.docs.map((doc) {
        return Task.fromFirestore(doc.data() as Map<String, dynamic>);
      }).toList();
      print(" project id ${projectTasks[1].id} ");

      return projectTasks;
    } catch (e) {
      print('Error fetching user projects: $e');
      return [];
    }
  }

  Future<void> updateTaskStatus(String taskId, String newStatus) async {
    try {
      await tasksCollection // Replace with your tasks collection name
          .doc(taskId)
          .update({'status': newStatus});
    } catch (e) {
      print(taskId);
      print('Error updating task status: $e');
    }
  }

  Future<List<MyUser>> fetchCollaborators(String projectId) async {
    try {
      // Reference to the projects collection
      DocumentSnapshot projectDoc =
          await projectCollection.doc(projectId).get();

      // Ensure that the project document exists
      if (!projectDoc.exists) {
        print('Project not found');
        return [];
      }

      // Fetch the collaborator IDs from the project document
      List<String> collaboratorIds =
          List<String>.from(projectDoc['collaboratorIds']);

      // If there are no collaborators, return an empty list
      if (collaboratorIds.isEmpty) {
        print('No collaborators found');
        return [];
      }

      // Fetch user documents for each collaborator ID
      List<MyUser> collaborators = [];
      for (String collaboratorId in collaboratorIds) {
        DocumentSnapshot userDoc =
            await userCollection.doc(collaboratorId).get();
        if (userDoc.exists) {
          // Assuming User.fromFirestore is defined to create a User object from Firestore data
          collaborators.add(
              MyUser.fromFirestore(userDoc.data() as Map<String, dynamic>));
        } else {
          print('User not found for ID: $collaboratorId');
        }
      }

      return collaborators; // Return the list of collaborators
    } catch (e) {
      print('Error fetching collaborators: $e');
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
