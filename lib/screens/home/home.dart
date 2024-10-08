import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:motion_app/models/project.dart';
import 'package:motion_app/screens/home/new_project.dart';
import 'package:motion_app/screens/home/project_view.dart';
import 'package:motion_app/screens/home/settings.dart';
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

  bool _isFreeUser = true; // Default to free user
  User? user = FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();
    _checkUserPlan(); // Check if the current user is free or pro
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
    List<Project> loadedProjects =
        await DatabaseService(uid: user!.uid).getUserProjects(user!.uid);
    setState(() {
      _projects = loadedProjects;
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
        backgroundColor: Colors.blue[400],
        elevation: 0.0,
        actions: [
          TextButton.icon(
            onPressed: () async {
              await _auth.signOut();
            },
            icon: const Icon(Icons.logout, color: Colors.white),
            label: const Text(
              'Signout',
              style: TextStyle(color: Colors.white),
            ),
          ),
          TextButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SettingsPage()),
              );
            },
            icon: const Icon(Icons.person, color: Colors.white),
            label: const Text(
              'Settings',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Center(
            heightFactor: 2,
            child: ElevatedButton(
              onPressed: () {
                // Navigate to project creation screen
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => NewProjectScreen()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                padding:
                    const EdgeInsets.symmetric(horizontal: 50, vertical: 20),
                textStyle: const TextStyle(fontSize: 20),
              ),
              child: const Text('+ New Project',
                  style: TextStyle(color: Colors.white)),
            ),
          ),
          Expanded(
            child: _projects.isEmpty
                ? const Center(
                    child:
                        Text('No projects yet! Tap + New Project to add one.'),
                  )
                : ListView.builder(
                    itemCount: _projects.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        title: Text(_projects[index].title),
                        subtitle: Text(_projects[index].description),
                        trailing: IconButton(
                          icon: const Icon(Icons.more_vert),
                          onPressed: () {
                            print(_projects[index].id);
                          },
                        ),
                        onTap: () {
                          if (_projects[index].id.isNotEmpty) {
                            // Check if the project ID is not empty
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ProjectDetailsWidget(
                                    projectId: _projects[index].id),
                              ),
                            );
                          } else {
                            print(
                                'Error: Project ID is empty.'); // Debug output
                          }
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
