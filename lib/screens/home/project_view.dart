import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:motion_app/models/project.dart';
import 'package:motion_app/models/user.dart';
import 'package:motion_app/screens/home/comment.dart';
import 'package:motion_app/screens/home/invitation.dart';
import 'package:motion_app/screens/home/task_form.dart';
import 'package:motion_app/services/database.dart';

class ProjectDetailsWidget extends StatefulWidget {
  final String projectId;

  const ProjectDetailsWidget({super.key, required this.projectId});

  @override
  _ProjectDetailsWidgetState createState() => _ProjectDetailsWidgetState();
}

class _ProjectDetailsWidgetState extends State<ProjectDetailsWidget> {
  User? user = FirebaseAuth.instance.currentUser;

  Future<Project> fetchProjectDetails() async {
    DocumentSnapshot doc = await FirebaseFirestore.instance
        .collection('projects')
        .doc(widget.projectId)
        .get();
    return Project.fromDocument(doc);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Project>(
      future: fetchProjectDetails(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return const Center(child: Text('Error fetching project details.'));
        } else if (!snapshot.hasData) {
          return const Center(
              child: Text(
            'Project not found.',
          ));
        } else {
          Project project = snapshot.data!;

          return Scaffold(
            appBar: AppBar(
              title: Text(project.title,
                  style: const TextStyle(fontSize: 24, color: Colors.white)),
              backgroundColor: Colors.blueAccent,
              actions: [
                IconButton(
                  icon: const Icon(
                    Icons.person_add,
                    color: Colors.white,
                  ),
                  onPressed: () async {
                    showDialog(
                      context: context,
                      builder: (context) => SendInvitationWidget(
                        projectId: project.id,
                        projectName: project.title,
                      ),
                    );
                  },
                ),
                IconButton(
                  icon: const Icon(
                    Icons.comment,
                    color: Colors.white,
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CommentScreen(
                          projectId: widget
                              .projectId, // Pass project ID to the comment screen
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
            body: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Project Description',
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text(project.description,
                      style:
                          const TextStyle(fontSize: 16, color: Colors.black54)),
                  const SizedBox(height: 16),
                  const Text('Tasks',
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  StreamBuilder<List<Task>>(
                    stream: DatabaseService(uid: user!.uid)
                        .getTasksStream(project.id), // Task stream
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      } else if (snapshot.hasError) {
                        return const Center(
                            child: Text('Error fetching tasks.'));
                      } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return const Center(child: Text('No tasks available.'));
                      } else {
                        List<Task> tasks = snapshot.data!;

                        return Expanded(
                          child: ListView.builder(
                            itemCount: tasks.length,
                            itemBuilder: (context, index) {
                              Task task = tasks[index];
                              bool isCompleted = task.status == 'Completed';

                              return Card(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: ListTile(
                                  title: Text(
                                    task.title,
                                    style: TextStyle(
                                      decoration: isCompleted
                                          ? TextDecoration.lineThrough
                                          : null,
                                    ),
                                  ),
                                  subtitle: Text(task.description),
                                  trailing: Checkbox(
                                    value: isCompleted,
                                    checkColor: Colors.indigo,
                                    fillColor: const WidgetStatePropertyAll(
                                        Colors.white),
                                    onChanged: (bool? value) async {
                                      // Toggle task completion status
                                      String newStatus =
                                          isCompleted ? 'Pending' : 'Completed';
                                      await DatabaseService(uid: user!.uid)
                                          .updateTaskStatus(task.id, newStatus);
                                      setState(() {
                                        task.status =
                                            newStatus; // Update local state
                                      });
                                    },
                                  ),
                                ),
                              );
                            },
                          ),
                        );
                      }
                    },
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () {
                      _showTaskForm(context, project.id);
                    },
                    icon: const Icon(
                      Icons.add,
                      color: Colors.white,
                    ),
                    label: const Text(
                      "Add Task",
                      style: TextStyle(color: Colors.white),
                    ),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 16),
                      backgroundColor: Colors.blueAccent,
                    ),
                  ),
                ],
              ),
            ),
          );
        }
      },
    );
  }

  void _showTaskForm(BuildContext context, String projectId) async {
    List<MyUser> collaborators =
        await DatabaseService(uid: user!.uid).fetchCollaborators(projectId);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: TaskForm(
            onCreateTask: (Task newTask) {
              DatabaseService(uid: user!.uid).updateTaskData(
                newTask.id,
                newTask.title,
                newTask.description,
                projectId,
                newTask.assignedTo,
                newTask.status,
                newTask.createdAt,
                newTask.dueDate,
              );
            },
            collaborators: collaborators,
          ),
        );
      },
    );
  }
}
