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
        backgroundColor: Colors.indigo[600],
        elevation: 0,
        title: Text(
          'Projects',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SettingsPage()),
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
    return StreamBuilder<List<Project>>(
      stream: DatabaseService(uid: user!.uid).getProjectStream(user!.uid),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return const Center(child: Text('Error fetching projects.'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return _buildEmptyState();
        } else {
          List<Project> projects = snapshot.data!;
          return ListView.builder(
            padding: const EdgeInsets.all(8),
            itemCount: projects.length,
            itemBuilder: (context, index) {
              return Card(
                elevation: 3,
                margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: ListTile(
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
                  trailing: IconButton(
                    icon: const Icon(Icons.more_vert),
                    onPressed: () {
                      _showProjectActions(context, projects[index]);
                    },
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
      },
    );
  }

  void _showProjectActions(BuildContext context, Project project) {
    // Define actions like edit, delete, etc. for projects.
  }
}
