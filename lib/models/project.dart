import 'package:cloud_firestore/cloud_firestore.dart';


class Project {
  final String id;
  final String title;
  final String description;
  final String? ownerId; // ID of the user who created the project
  final DateTime? createdAt;
  final DateTime? updatedAt;
  bool isArchived = false;
  final List<String>? collaboratorIds; // List of collaborator user IDs
  final List<Task>? tasks; // List of tasks related to the project

  Project({
    required this.id,
    required this.title,
    required this.description,
    this.ownerId,
    this.createdAt,
    this.updatedAt,
    required this.isArchived,
    this.collaboratorIds,
    this.tasks,
  });

  // Factory constructor to create a Project from Firestore document
  factory Project.fromFirestore(Map<String, dynamic> data) {
    return Project(
      id: data['projectId'] ?? '',
      ownerId: data['ownerId'] ?? '',
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      isArchived: data['isArchived']
      // Initialize other fields here
    );
  }

  factory Project.fromDocument(DocumentSnapshot doc) {
    return Project(
      id: doc.id,
      title: doc['title'],
      description: doc['description'],
      ownerId: doc['ownerId'],
      isArchived: doc['isArchived'],
    );
  }
}

class Task {
  final String id;
  final String title;
  final String description;
  final String projectId; // ID of the related project
  final String assignedTo; // User ID of the assigned collaborator
  String status; // E.g., 'open', 'in-progress', 'completed'
  final DateTime dueDate;
  final DateTime createdAt;

  Task({
    required this.id,
    required this.title,
    required this.description,
    required this.projectId,
    required this.assignedTo,
    required this.status,
    required this.dueDate,
    required this.createdAt,
  });

  // Factory constructor to create a Project from Firestore document
  factory Task.fromFirestore(Map<String, dynamic> data) {
    return Task(
      id: data['taskId'] ?? '',
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      projectId: data['projectId'] ?? '',
      assignedTo: data['assignedTo'] ?? '',
      status: data['status'] ?? '',
      createdAt: (data['createdAt'] as Timestamp)
          .toDate(), // Convert Timestamp to DateTime
      dueDate: (data['dueDate'] as Timestamp).toDate(),

      // Initialize other fields here
    );
  }
}

class Comment {
  final String id;
  final String content;
  final String userId; // ID of the user who made the comment
  final String projectId; // ID of the project the comment is related to
  final DateTime createdAt;

  Comment({
    required this.id,
    required this.content,
    required this.userId,
    required this.projectId,
    required this.createdAt,
  });


  // Factory constructor to create a Project from Firestore document
  factory Comment.fromFirestore(Map<String, dynamic> data) {
    return Comment(
      id: data['taskId'] ?? '',
      content: data['content'] ?? '',
      userId: data['userId'] ?? '',
      projectId: data['projectId'] ?? '',
      createdAt: (data['createdAt'] as Timestamp)
          .toDate(), // Convert Timestamp to DateTime

      // Initialize other fields here
    );
  }
}

class Invitation {
  final String id;
  final String projectId;
  final String senderId; // The user who sent the invitation
  final String receiverId; // The user being invited
  final String projectName;
  final DateTime sentAt;
  bool isAccepted;

  Invitation({
    required this.id,
    required this.projectId,
    required this.senderId,
    required this.receiverId,
    required this.projectName,
    required this.sentAt,
    this.isAccepted = false,
  });

  // To convert Invitation object to a Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'projectId': projectId,
      'senderId': senderId,
      'receiverId': receiverId,
      'projectName': projectName,
      'sentAt': sentAt.toIso8601String(),
      'isAccepted': isAccepted,
    };
  }

  // To create an Invitation object from a Firestore document
  factory Invitation.fromMap(Map<String, dynamic> data) {
    return Invitation(
      id: data['id'],
      projectId: data['projectId'],
      senderId: data['senderId'],
      receiverId: data['receiverId'],
      projectName: data['projectName'],
      sentAt: DateTime.parse(data['sentAt']),
      isAccepted: data['isAccepted'] ?? false,
    );
  }
}
