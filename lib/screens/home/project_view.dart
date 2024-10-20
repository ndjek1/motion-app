import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:motion_app/models/project.dart';
import 'package:motion_app/models/user.dart';
import 'package:motion_app/screens/home/comment.dart';
import 'package:motion_app/screens/home/invitation.dart';
import 'package:motion_app/screens/home/task_form.dart';
import 'package:motion_app/services/database.dart';

import 'package:fl_chart/fl_chart.dart';

class ProjectDetailsWidget extends StatefulWidget {
  final String projectId;

  const ProjectDetailsWidget({super.key, required this.projectId});

  @override
  _ProjectDetailsWidgetState createState() => _ProjectDetailsWidgetState();
}

class _ProjectDetailsWidgetState extends State<ProjectDetailsWidget> {
  User? user = FirebaseAuth.instance.currentUser;
  late List<Task> tasks;
  int pendingTaskCount = 0;
  int inProgressTaskCount = 0;
  int completedTaskCount = 0;

  Future<Project> fetchProjectDetails() async {
    DocumentSnapshot doc = await FirebaseFirestore.instance
        .collection('projects')
        .doc(widget.projectId)
        .get();
    return Project.fromDocument(doc);
  }

  Future<double> fetchProjectProgress() async {
    return await DatabaseService(uid: user!.uid)
        .calculateProjectProgress(widget.projectId);
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
          return const Center(child: Text('Project not found.'));
        } else {
          Project project = snapshot.data!;

          return Scaffold(
            appBar: AppBar(
              title: Text(project.title,
                  style: const TextStyle(fontSize: 24, color: Colors.white)),
              backgroundColor: Colors.blueAccent,
              actions: [
                IconButton(
                  icon: const Icon(Icons.person_add, color: Colors.white),
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
                  icon: const Icon(Icons.comment, color: Colors.white),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CommentScreen(
                          projectId: widget.projectId,
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
                  FutureBuilder<double>(
                    future: fetchProjectProgress(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      } else if (snapshot.hasError) {
                        return const Text('Error calculating progress');
                      } else if (!snapshot.hasData) {
                        return const Text('No progress data available');
                      } else {
                        double progress = snapshot.data!;

                        return Column(
                          children: [
                            const Text('Project Progress',
                                style: TextStyle(
                                    fontSize: 20, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 8),
                            Center(
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  SizedBox(
                                    width: 150,
                                    height: 150,
                                    child: CircularProgressIndicator(
                                      value: progress / 100,
                                      backgroundColor: Colors.grey[300],
                                      strokeWidth: 8,
                                      valueColor:
                                          const AlwaysStoppedAnimation<Color>(
                                              Colors.blueAccent),
                                    ),
                                  ),
                                  Text(
                                    '${progress.toStringAsFixed(1)}%',
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 16),
                            const Text('Task Progress',
                                style: TextStyle(
                                    fontSize: 20, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 8),
                            // _buildBarChart(),
                          ],
                        );
                      }
                    },
                  ),
                  const SizedBox(height: 16),
                  const Text('Tasks',
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  // Task list stream builder here...
                  StreamBuilder<List<Task>>(
                    stream: DatabaseService(uid: user!.uid)
                        .getTasksStream(project.id),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      } else if (snapshot.hasError) {
                        return const Center(
                            child: Text('Error fetching tasks.'));
                      } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return const Center(child: Text('No tasks available.'));
                      } else {
                        tasks = snapshot.data!;

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
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      PopupMenuButton<int>(
                                        icon: const Icon(Icons.more_vert,
                                            color: Colors.indigo),
                                        onSelected: (value) async {
                                          if (value == 1) {
                                            _showTaskForm(context, project.id,
                                                task:
                                                    task); // Pass task for editing
                                          } else if (value == 2) {
                                            String newStatus = isCompleted
                                                ? 'Pending'
                                                : 'Completed';
                                            await DatabaseService(
                                                    uid: user!.uid)
                                                .updateTaskStatus(
                                                    task.id, newStatus);
                                            setState(() {
                                              task.status = newStatus;
                                            });
                                          } else if (value == 3) {
                                            String response =
                                                DatabaseService(uid: user!.uid)
                                                        .deleteTask(task.id)
                                                    as String;
                                            print(response);
                                          }
                                        },
                                        itemBuilder: (BuildContext context) =>
                                            <PopupMenuEntry<int>>[
                                          const PopupMenuItem<int>(
                                            value: 1,
                                            child: Row(
                                              children: [
                                                Icon(Icons.edit),
                                                SizedBox(width: 8),
                                                Text('Edit'),
                                              ],
                                            ),
                                          ),
                                          const PopupMenuItem<int>(
                                            value: 2,
                                            child: Row(
                                              children: [
                                                Icon(Icons.check),
                                                SizedBox(width: 8),
                                                Text('Mark as done'),
                                              ],
                                            ),
                                          ),
                                          const PopupMenuItem<int>(
                                            value: 3,
                                            child: Row(
                                              children: [
                                                Icon(Icons.delete),
                                                SizedBox(width: 8),
                                                Text('Delete'),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                      Icon(Icons.check_circle,
                                          color: isCompleted
                                              ? Colors.green
                                              : Colors.grey)
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        );
                      }
                    },
                  ),
                ],
              ),
            ),
          );
        }
      },
    );
  }

  Widget _buildBarChart() {
    return BarChart(
      BarChartData(
        barGroups: [
          BarChartGroupData(
            x: 0,
            barRods: [
              BarChartRodData(
                toY: pendingTaskCount.toDouble(),
                color: Colors.redAccent,
                width: 16,
              ),
            ],
          ),
          BarChartGroupData(
            x: 1,
            barRods: [
              BarChartRodData(
                toY: inProgressTaskCount.toDouble(),
                color: Colors.orangeAccent,
                width: 16,
              ),
            ],
          ),
          BarChartGroupData(
            x: 2,
            barRods: [
              BarChartRodData(
                toY: completedTaskCount.toDouble(),
                color: Colors.greenAccent,
                width: 16,
              ),
            ],
          ),
        ],
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (double value, TitleMeta meta) {
                switch (value.toInt()) {
                  case 0:
                    return const Text('Pending');
                  case 1:
                    return const Text('In Progress');
                  case 2:
                    return const Text('Completed');
                  default:
                    return const Text('');
                }
              },
            ),
          ),
        ),
        borderData: FlBorderData(show: false),
      ),
    );
  }

  void _showTaskForm(BuildContext context, String projectId,
      {Task? task}) async {
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
            onSubmitTask: (Task editedTask) {
              // If task is provided, update the task; otherwise, create a new task
              if (task != null) {
                DatabaseService(uid: user!.uid).updateTaskData(
                  editedTask.id,
                  editedTask.title,
                  editedTask.description,
                  editedTask.projectId,
                  editedTask.assignedTo,
                  editedTask.status,
                  editedTask.createdAt,
                  editedTask.dueDate,
                );
              } else {
                // For creating a new task
                DatabaseService(uid: user!.uid).updateTaskData(
                  editedTask.id,
                  editedTask.title,
                  editedTask.description,
                  projectId,
                  editedTask.assignedTo,
                  editedTask.status,
                  editedTask.createdAt,
                  editedTask.dueDate,
                );
              }
            },
            collaborators: collaborators,
            task: task, // Pass the task for editing
          ),
        );
      },
    );
  }
}
