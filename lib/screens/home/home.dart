import 'package:flutter/material.dart';
import 'package:motion_app/models/project.dart';
import 'package:motion_app/screens/home/new_project.dart';
import 'package:motion_app/services/auth.dart';
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

  @override
  void initState() {
    super.initState();
    _loadProjects();
  }

  Future<void> _loadProjects() async {
    List<Project> loadedProjects = await _localStorageService.loadProjects();
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
        title: const Text('Project Tracker'),
        backgroundColor: Colors.green[400],
        elevation: 0.0,
        actions: [
          TextButton.icon(
            onPressed: () async {
              await _auth.signOut();
            },
            icon: const Icon(Icons.person, color: Colors.white),
            label: const Text(
              'Signout',
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
                            _deleteProject(index);
                          },
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
