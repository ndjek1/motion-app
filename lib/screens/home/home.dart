import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:motion_app/models/project.dart';
import 'package:motion_app/screens/home/invitations_list.dart';
import 'package:motion_app/screens/home/new_project.dart';
import 'package:motion_app/screens/home/profile.dart';
import 'package:motion_app/screens/home/project_view.dart';
import 'package:motion_app/services/auth.dart';
import 'package:motion_app/services/database.dart';
import 'package:motion_app/services/local_storage.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final AuthService _auth = AuthService();
  final LocalStorageService _localStorageService = LocalStorageService();
  List<Project> _projects = [];
  List<Project> _invitedProjects = [];

  bool _isFreeUser = true; // Default to free user
  User? user = FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();
    _checkUserPlan();
    _loadProjects();
  }

  Future<void> _checkUserPlan() async {
    if (user != null) {
      bool isFreeUser =
          await DatabaseService(uid: user!.uid).isFreeUser(user!.uid);
      setState(() {
        _isFreeUser = isFreeUser;
      });
    }
  }

  Future<void> _loadProjects() async {
    // Fetch owned projects
    List<Project> ownedProjects =
        await DatabaseService(uid: user!.uid).getUserProjects(user!.uid);

    // Fetch invited projects
    List<Project> invitedProjects =
        await DatabaseService(uid: user!.uid).getUserInvitedProjects(user!.uid);

    // Combine them in the state
    setState(() {
      _projects = ownedProjects;
      _invitedProjects = invitedProjects; // Add this new list
    });
  }

  Future<void> _deleteProject(int index) async {
    await _localStorageService.deleteProject(index, _projects);
    setState(() {
      _projects.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.indigo[600],
        elevation: 0,
        title: const Text(
          'Projects',
          style: TextStyle(
              fontWeight: FontWeight.bold, fontSize: 24, color: Colors.white),
        ),
        leading: PopupMenuButton<int>(
          icon: const Icon(Icons.menu, color: Colors.white), // The menu icon
          onSelected: (value) {
            // Handle the selected menu item here
            if (value == 1) {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ProfileWidget()),
              );
            } else if (value == 2) {
              print("Privacy selected");
            } else if (value == 3) {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => InvitationListWidget()),
              );
            }
          },
          itemBuilder: (BuildContext context) => <PopupMenuEntry<int>>[
            const PopupMenuItem<int>(
              value: 1, // Assign a value to the first option
              child: Row(
                children: [
                  Icon(Icons.person),
                  SizedBox(width: 8), // Add space between the icon and text
                  Text('Profile'),
                ],
              ),
            ),
            const PopupMenuItem<int>(
              value: 2, // Assign a value to the second option
              child: Row(
                children: [
                  Icon(Icons.lock),
                  SizedBox(width: 8),
                  Text('Privacy'),
                ],
              ),
            ),
            const PopupMenuItem<int>(
              value: 3, // Assign a value to the third option
              child: Row(
                children: [
                  Icon(Icons.notifications),
                  SizedBox(width: 8),
                  Text('Notifications'),
                ],
              ),
            ),
            const PopupMenuItem<int>(
              value: 3, // Assign a value to the third option
              child: Row(
                children: [
                  Icon(Icons.settings),
                  SizedBox(width: 8),
                  Text('Settings'),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () async {
              await _auth.signOut();
            },
          ),
        ],
      ),
      body: _projects.isEmpty ? _buildEmptyState() : _buildProjectList(context),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => NewProjectScreen()),
          );
        },
        backgroundColor: Colors.indigo[600],
        child: const Icon(
          Icons.add,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.folder_open, size: 100, color: Colors.grey[400]),
          const SizedBox(height: 20),
          Text(
            'No projects yet!',
            style: TextStyle(
              fontSize: 20,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Tap + to create your first project.',
            style: TextStyle(color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  Widget _buildProjectList(BuildContext context) {
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
          _projects.isEmpty
              ? _buildEmptyState()
              : ListView.builder(
                  shrinkWrap: true, // To avoid scroll conflicts
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _projects.length,
                  itemBuilder: (context, index) {
                    return Card(
                      elevation: 3,
                      margin: const EdgeInsets.symmetric(
                          vertical: 8, horizontal: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: ListTile(
                        leading: const Icon(
                          Icons.note,
                          size: 40.0,
                          color: Colors.indigo,
                        ),
                        contentPadding: const EdgeInsets.all(16),
                        title: Text(
                          _projects[index].title,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                        subtitle: Text(
                          _projects[index].description,
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
                              builder: (context) => ProjectDetailsWidget(
                                  projectId: _projects[index].id),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
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
          _invitedProjects.isEmpty
              ? const Center(child: Text('No invited projects yet.'))
              : ListView.builder(
                  shrinkWrap: true, // To avoid scroll conflicts
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _invitedProjects.length,
                  itemBuilder: (context, index) {
                    return Card(
                      elevation: 3,
                      margin: const EdgeInsets.symmetric(
                          vertical: 8, horizontal: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: ListTile(
                        leading: const Icon(
                          Icons.note,
                          size: 40.0,
                          color: Colors.indigo,
                        ),
                        contentPadding: const EdgeInsets.all(16),
                        title: Text(
                          _invitedProjects[index].title,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                        subtitle: Text(
                          _invitedProjects[index].description,
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
                              builder: (context) => ProjectDetailsWidget(
                                  projectId: _invitedProjects[index].id),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
        ],
      ),
    );
  }

  void _showProjectActions(BuildContext context, Project project) {
    // Define actions like edit, delete, etc. for projects.
  }
}
