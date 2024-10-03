import 'package:flutter/material.dart';
import 'package:motion_app/models/project.dart';
import 'package:motion_app/services/local_storage.dart';

class NewProjectScreen extends StatefulWidget {
  @override
  _NewProjectScreenState createState() => _NewProjectScreenState();
}

class _NewProjectScreenState extends State<NewProjectScreen> {
  final _formKey = GlobalKey<FormState>();
  String _title = '';
  String _description = '';

  // Initialize the LocalStorageService
  final LocalStorageService _localStorageService = LocalStorageService();
  List<Project> _currentProjects = [];

  @override
  void initState() {
    super.initState();
    _loadCurrentProjects();
  }

  // Load the existing projects
  Future<void> _loadCurrentProjects() async {
    _currentProjects = await _localStorageService.loadProjects();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create New Project'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                decoration: const InputDecoration(labelText: 'Project Title'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a project title';
                  }
                  return null;
                },
                onSaved: (value) {
                  _title = value!;
                },
              ),
              TextFormField(
                decoration:
                    const InputDecoration(labelText: 'Project Description'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a project description';
                  }
                  return null;
                },
                onSaved: (value) {
                  _description = value!;
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    _formKey.currentState!.save();

                    // Create a new Project object
                    Project newProject =
                        Project(title: _title, description: _description);

                    // Save the project using LocalStorageService
                    await _localStorageService.saveProject(
                        newProject, _currentProjects);
                    print("Project saved");

                    // Navigate back and pass the new project
                    Navigator.pop(context, newProject);
                  }
                },
                child: const Text('Create Project'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
