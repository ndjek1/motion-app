import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:motion_app/models/project.dart';
import 'package:motion_app/services/database.dart';
import 'package:uuid/uuid.dart';

class NewProjectScreen extends StatefulWidget {
  @override
  _NewProjectScreenState createState() => _NewProjectScreenState();
}

class _NewProjectScreenState extends State<NewProjectScreen> {
  final _formKey = GlobalKey<FormState>();
  String _title = '';
  String _description = '';
  DateTime _dueDate = DateTime.now();
  final Uuid _uuid = Uuid(); // Initialize UUID generator

  bool _isFreeUser = true; // Default to free user
  User? user = FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();
    _checkUserPlan(); // Check if the current user is free or pro
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
              _buildDatePicker(
                label: 'Due Date',
                selectedDate: _dueDate,
                onDatePicked: (pickedDate) {
                  setState(() {
                    _dueDate = pickedDate!;
                  });
                },
              ),
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    _formKey.currentState!.save();
                    String projectId = _uuid.v4();
                    // Get the current time
                    DateTime createdAt = DateTime.now();
                    // Create a new Project object
                    Project newProject = Project(
                      id: projectId,
                      title: _title,
                      description: _description,
                      isArchived: false,
                    );

                    DatabaseService(uid: user!.uid).updateProjectData(
                        projectId,
                        _title,
                        _description,
                        _dueDate,
                        user!.uid,
                        createdAt.toString(),
                        null,
                        false,
                        null,
                        null);
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

  Widget _buildDatePicker({
    required String label,
    required DateTime selectedDate,
    required ValueChanged<DateTime?> onDatePicked,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        decoration: InputDecoration(
          labelText: label,
          suffixIcon: IconButton(
            icon: Icon(Icons.calendar_today, color: Colors.indigo),
            onPressed: () async {
              DateTime? pickedDate = await showDatePicker(
                context: context,
                initialDate: selectedDate,
                firstDate: DateTime.now(),
                lastDate: DateTime(2100),
              );
              if (pickedDate != null) {
                onDatePicked(pickedDate);
              }
            },
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
        ),
        readOnly: true,
        controller: TextEditingController(
            text: DateFormat('yyyy-MM-dd').format(selectedDate)),
      ),
    );
  }
}
