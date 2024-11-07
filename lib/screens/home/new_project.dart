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
  final Uuid _uuid = Uuid();
  User? user = FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();
    _checkUserPlan();
  }

  Future<void> _checkUserPlan() async {
    if (user != null) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Create New Project'),
        backgroundColor: Colors.grey[850],
        elevation: 2,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildCardField(
                label: 'Project Title',
                hint: 'Enter project title',
                onSaved: (value) => _title = value!,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a project title';
                  }
                  return null;
                },
              ),
              _buildCardField(
                label: 'Project Description',
                hint: 'Enter project description',
                onSaved: (value) => _description = value!,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a project description';
                  }
                  return null;
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
              const Spacer(),
              Center(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.indigo,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 30, vertical: 12),
                  ),
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      _formKey.currentState!.save();
                      String projectId = _uuid.v4();
                      DateTime createdAt = DateTime.now();
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
                      Navigator.pop(context, newProject);
                    }
                  },
                  child: const Text(
                    'Create Project',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCardField({
    required String label,
    required String hint,
    required FormFieldSetter<String> onSaved,
    required FormFieldValidator<String> validator,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: TextFormField(
            decoration: InputDecoration(
              labelText: label,
              hintText: hint,
              border: InputBorder.none,
            ),
            onSaved: onSaved,
            validator: validator,
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
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
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
              border: InputBorder.none,
            ),
            readOnly: true,
            controller: TextEditingController(
              text: DateFormat('yyyy-MM-dd').format(selectedDate),
            ),
          ),
        ),
      ),
    );
  }
}
