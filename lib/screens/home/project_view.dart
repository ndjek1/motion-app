import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:motion_app/models/project.dart';
import 'package:motion_app/screens/home/invitation.dart';

class ProjectDetailsWidget extends StatelessWidget {
  final String projectId;

  const ProjectDetailsWidget({super.key, required this.projectId});

  Future<Project> fetchProjectDetails() async {
    print('Fetching details for project ID: $projectId'); // Debug output
    DocumentSnapshot doc = await FirebaseFirestore.instance
        .collection('projects')
        .doc(projectId)
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
          return const Center(child: Text('Project not found.'));
        } else {
          Project project = snapshot.data!;

          return Scaffold(
            appBar: AppBar(
              title: Text(project.title),
              backgroundColor: Colors.blue[400],
              actions: [
                TextButton.icon(
                  onPressed: () async {
                    showDialog(
                      context: context,
                      builder: (context) => SendInvitationWidget(
                        projectId: project.id,
                        projectName: project.title,
                      ),
                    );
                  },
                  icon: const Icon(Icons.person, color: Colors.white),
                  label: const Text(
                    'Add people',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
            body: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Project title',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8.0),
                  Text(project.title),
                  const SizedBox(height: 16.0),
                  const Text(
                    'Description',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8.0),
                  Text(project.description),
                  const SizedBox(height: 16.0),
                  const Text(
                    'List of tasks',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          );
        }
      },
    );
  }
}
