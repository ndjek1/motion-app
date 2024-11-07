import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:motion_app/models/project.dart'; // Import Task model
import 'package:motion_app/models/user.dart'; // Import User model
import 'package:motion_app/services/database.dart'; // Database service for Firebase

class TaskForm extends StatefulWidget {
  final Function(Task) onSubmitTask;
  final List<MyUser> collaborators;
  final Task? task; // Task to edit, or null if creating a new task
  final String project_id; //
  final User? user = FirebaseAuth.instance.currentUser;

  TaskForm(
      {required this.onSubmitTask, required this.collaborators, this.task, required this.project_id});

  @override
  _TaskFormState createState() => _TaskFormState();
}

class _TaskFormState extends State<TaskForm> {
  final _formKey = GlobalKey<FormState>();
  late String _title;
  late String _description;
  late String _assignedTo;
  late String _status;
  late DateTime _dueDate;

  @override
  void initState() {
    super.initState();
    // If editing a task, initialize with its values; otherwise use defaults
    _title = widget.task?.title ?? '';
    _description = widget.task?.description ?? '';
    _assignedTo = widget.task?.assignedTo ?? '';
    _status = widget.task?.status ?? 'Pending';
    _dueDate = widget.task?.dueDate ?? DateTime.now();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Text(
                  widget.task == null ? 'Create Activity' : 'Edit Activity',
                  style: Theme.of(context).textTheme.titleLarge!.copyWith(
                      fontWeight: FontWeight.bold, color: Colors.indigo),
                ),
              ),
              const SizedBox(height: 20),
              _buildTextField(
                label: 'Activity Title',
                hint: 'Enter activity title',
                initialValue: _title,
                onSave: (value) => _title = value!,
                validator: (value) =>
                    value!.isEmpty ? 'Please enter a activity title' : null,
              ),
              _buildTextField(
                label: 'Description',
                hint: 'Enter activity description',
                initialValue: _description,
                onSave: (value) => _description = value!,
                maxLines: 3,
              ),
              _buildDropdown(
                label: 'Assigned To',
                value: _assignedTo.isNotEmpty ? _assignedTo : null,
                items: widget.collaborators.map((collaborator) {
                  return DropdownMenuItem(
                    value: collaborator.uid,
                    child:
                        Text(collaborator.displayName ?? collaborator.email!),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _assignedTo = value!;
                  });
                },
              ),
              _buildDropdown(
                label: 'Status',
                value: _status,
                items: ['Pending', 'inProgress', 'Completed'].map((status) {
                  return DropdownMenuItem<String>(
                    value: status,
                    child: Text(status),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _status = value!;
                  });
                },
              ),
              _buildDatePicker(
                label: 'Due Date',
                selectedDate: _dueDate,
                onDatePicked: (pickedDate) {
                  setState(() {
                    _dueDate = pickedDate!;
                  });
                },
              ),
              const SizedBox(height: 20),
              Center(
                child: ElevatedButton(
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      _formKey.currentState!.save();

                      Task newTask = Task(
                        id: widget.task?.id ?? DateTime.now().toString(),
                        title: _title,
                        description: _description,
                        projectId: widget.project_id, // Ensure projectId is set
                        assignedTo: _assignedTo,
                        status: _status,
                        dueDate: _dueDate,
                        createdAt: widget.task?.createdAt ?? DateTime.now(),
                      );

                      await DatabaseService(uid: widget.user!.uid)
                          .updateTaskData(
                        newTask.id,
                        newTask.title,
                        newTask.description,
                        newTask.projectId,
                        newTask.assignedTo,
                        newTask.status,
                        newTask.createdAt,
                        newTask.dueDate,
                      );

                      widget.onSubmitTask(newTask);
                      Navigator.pop(context);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 16, horizontal: 32),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    backgroundColor: Colors.indigo, // Set the button color
                  ),
                  child: Text(
                    widget.task == null ? 'Create Activity' : 'Update Activity',
                    style: const TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required String hint,
    required String initialValue,
    required FormFieldSetter<String> onSave,
    FormFieldValidator<String>? validator,
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
        ),
        initialValue: initialValue,
        maxLines: maxLines,
        onSaved: onSave,
        validator: validator,
      ),
    );
  }

  Widget _buildDropdown<T>({
    required String label,
    required T? value,
    required List<DropdownMenuItem<T>> items,
    required ValueChanged<T?> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: DropdownButtonFormField<T>(
        value: value,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
        ),
        items: items,
        onChanged: onChanged,
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

// Usage Example
void showTaskForm(BuildContext context, Function(Task) onSubmitTask,
    List<MyUser> collaborators,String project_id,
    {Task? task}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    builder: (context) => TaskForm(
      onSubmitTask: onSubmitTask,
      collaborators: collaborators,
      task: task,
      project_id: project_id,
    ),
  );
}
