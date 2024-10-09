import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:motion_app/models/project.dart';
import 'package:intl/intl.dart';
import 'package:motion_app/models/user.dart';
import 'package:motion_app/services/database.dart'; // Ensure this is the correct import for your User model

class TaskForm extends StatefulWidget {
  final Function(Task) onCreateTask; // Callback to send the task data
  final List<MyUser> collaborators;
  User? user = FirebaseAuth.instance.currentUser;

  TaskForm({required this.onCreateTask, required this.collaborators});

  @override
  _TaskFormState createState() => _TaskFormState();
}

class _TaskFormState extends State<TaskForm> {
  final _formKey = GlobalKey<FormState>();
  String _title = '';
  String _description = '';
  String _assignedTo = '';
  String _status = 'open';
  DateTime _dueDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Create New Task',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Task Title'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a title';
                  }
                  return null;
                },
                onSaved: (value) {
                  _title = value!;
                },
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Description'),
                maxLines: 3,
                onSaved: (value) {
                  _description = value!;
                },
              ),
              DropdownButtonFormField<String>(
                decoration: InputDecoration(labelText: 'Assigned To'),
                value: _assignedTo.isNotEmpty ? _assignedTo : null,
                items: widget.collaborators.map((collaborator) {
                  return DropdownMenuItem(
                    value: collaborator
                        .uid, // Assuming MyUser has an 'id' property
                    child: Text(collaborator.displayName ??
                        collaborator.email!), // Display the collaborator's name
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _assignedTo = value!;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select a collaborator';
                  }
                  return null;
                },
              ),
              DropdownButtonFormField<String>(
                value: _status,
                items: ['Pending', 'Completed'].map((status) {
                  return DropdownMenuItem(
                    value: status,
                    child: Text(status),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _status = value!;
                  });
                },
                decoration: InputDecoration(labelText: 'Status'),
              ),
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Due Date',
                  suffixIcon: IconButton(
                    icon: Icon(Icons.calendar_today),
                    onPressed: () async {
                      DateTime? pickedDate = await showDatePicker(
                        context: context,
                        initialDate: _dueDate,
                        firstDate: DateTime.now(),
                        lastDate: DateTime(2100),
                      );
                      if (pickedDate != null) {
                        setState(() {
                          _dueDate = pickedDate;
                        });
                      }
                    },
                  ),
                ),
                readOnly: true,
                controller: TextEditingController(
                    text: DateFormat('yyyy-MM-dd').format(_dueDate)),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () async{
                  if (_formKey.currentState!.validate()) {
                    _formKey.currentState!.save();
                    // Create the new Task object
                    Task newTask = Task(
                      id: DateTime.now().toString(),
                      title: _title,
                      description: _description,
                      projectId: 'project_id', // Use the actual project ID
                      assignedTo: _assignedTo,
                      status: _status,
                      dueDate: _dueDate,
                      createdAt: DateTime.now(),
                    );
                    await DatabaseService(uid: widget.user!.uid).updateTaskData(
                        newTask.id,
                        newTask.title,
                        newTask.description,
                        newTask.projectId,
                        newTask.assignedTo,
                        newTask.status,
                        newTask.createdAt,
                        newTask.dueDate);
                    widget.onCreateTask(newTask); // Pass the task back
                    Navigator.pop(context); // Close the bottom sheet
                  }
                },
                child: const Text('Create Task'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Usage Example:
void showTaskForm(BuildContext context, Function(Task) onCreateTask,
    List<MyUser> collaborators) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    builder: (context) =>
        TaskForm(onCreateTask: onCreateTask, collaborators: collaborators),
  );
}
