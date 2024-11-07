import 'package:flutter/material.dart';
import 'package:motion_app/models/project.dart';
import 'package:motion_app/screens/home/invitations_list.dart';
import 'package:motion_app/screens/home/new_project.dart';
import 'package:motion_app/screens/home/privacy_terms_of_use.dart';
import 'package:motion_app/screens/home/profile.dart';
import 'package:motion_app/screens/home/project_view.dart';
import 'package:motion_app/screens/home/settings.dart';
import 'package:motion_app/services/auth.dart';
import 'package:motion_app/services/database.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final AuthService _auth = AuthService();
// Default to free user
  User? user = FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();
    // _checkUserPlan();
  }

  // Future<void> _checkUserPlan() async {
  //   if (user != null) {
  //     bool isFreeUser =
  //         await DatabaseService(uid: user!.uid).isFreeUser(user!.uid);
  //     setState(() {
  //       _isFreeUser = isFreeUser;
  //     });
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.grey[800], // Neutral dark grey color
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Projects',
          style: TextStyle(
              fontWeight: FontWeight.bold, fontSize: 24, color: Colors.white),
        ),
        leading: IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsPage()),
              );
            },
            icon: const Icon(Icons.settings)),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications, color: Colors.white),
            onPressed: () async {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => InvitationListWidget()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () async {
              await _auth.signOut();
            },
          ),
        ],
      ),
      body: _buildProjectList(context),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => NewProjectScreen()),
          );
        },
        backgroundColor: Colors.grey[700], // Neutral dark grey for FAB
        child: const Icon(
          Icons.add,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildProjectList(BuildContext context) {
    return StreamBuilder<List<Project>>(
      stream: DatabaseService(uid: user!.uid).getProjectStream(user!.uid),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final List<Project> ownedProjects = snapshot.data ?? [];
        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.all(8.0),
                child: Text(
                  'Your Projects',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              _buildOwnedProjectsList(ownedProjects),
              const Padding(
                padding: EdgeInsets.all(8.0),
                child: Text(
                  'Invited Projects',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              StreamBuilder<List<Project>>(
                stream: DatabaseService(uid: user!.uid)
                    .getInvitedProjectStream(user!.uid),
                builder: (context, invitedSnapshot) {
                  if (invitedSnapshot.hasError) {
                    return Center(
                        child: Text('Error: ${invitedSnapshot.error}'));
                  } else if (!invitedSnapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final List<Project> invitedProjects =
                      invitedSnapshot.data ?? [];
                  return _buildInvitedProjectsList(invitedProjects);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildOwnedProjectsList(List<Project> projects) {
    if (projects.isEmpty) {
      return _buildEmptyState('No owned projects yet!');
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: projects.length,
      itemBuilder: (context, index) {
        return Card(
          elevation: 3,
          margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          child: ListTile(
            trailing: PopupMenuButton<int>(
              icon: const Icon(
                Icons.more_vert,
                color: Colors.grey,
                size: 40.0,
              ),
              onSelected: (value) async {
                if (value == 1) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          ProjectDetailsWidget(projectId: projects[index].id),
                    ),
                  );
                } else if (value == 2) {
                  await DatabaseService(uid: user!.uid)
                      .archiveProject(projects[index].id);
                } else if (value == 3) {
                  _showDeleteConfirmationDialog(context, () async {
                    await DatabaseService(uid: user!.uid)
                        .deleteProject(projects[index].id);
                  });
                }
              },
              itemBuilder: (BuildContext context) => <PopupMenuEntry<int>>[
                const PopupMenuItem<int>(
                  value: 1,
                  child: Row(
                    children: [
                      Icon(Icons.notes_outlined, color: Colors.grey),
                      SizedBox(width: 8),
                      Text('View details'),
                    ],
                  ),
                ),
                const PopupMenuItem<int>(
                  value: 2,
                  child: Row(
                    children: [
                      Icon(Icons.done_all_sharp, color: Colors.grey),
                      SizedBox(width: 8),
                      Text('Completed'),
                    ],
                  ),
                ),
                const PopupMenuItem<int>(
                  value: 3,
                  child: Row(
                    children: [
                      Icon(Icons.delete_forever, color: Colors.red),
                      SizedBox(width: 8),
                      Text('Delete'),
                    ],
                  ),
                ),
              ],
            ),
            leading: const Icon(
              Icons.note,
              size: 40.0,
              color: Colors.grey,
            ),
            contentPadding: const EdgeInsets.all(16),
            title: Text(
              projects[index].title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            subtitle: Text(
              projects[index].description,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      ProjectDetailsWidget(projectId: projects[index].id),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildInvitedProjectsList(List<Project> projects) {
    if (projects.isEmpty) {
      return _buildEmptyState('No invited projects yet.');
    }
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: projects.length,
      itemBuilder: (context, index) {
        return Card(
          elevation: 3,
          margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          child: ListTile(
            leading: const Icon(
              Icons.note,
              size: 40.0,
              color: Colors.grey,
            ),
            contentPadding: const EdgeInsets.all(16),
            title: Text(
              projects[index].title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            subtitle: Text(
              projects[index].description,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      ProjectDetailsWidget(projectId: projects[index].id),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildEmptyState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.folder_open, size: 100, color: Colors.grey[400]),
          const SizedBox(height: 20),
          Text(
            message,
            style: TextStyle(
              fontSize: 20,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Tap + to create your first project.',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmationDialog(
      BuildContext context, VoidCallback onDelete) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Project'),
          content: const Text('Are you sure you want to delete this project?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
                onDelete(); // Call the delete function
              },
              child: const Text(
                'Delete',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }
}
