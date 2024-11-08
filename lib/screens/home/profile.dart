import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:motion_app/models/project.dart';
import 'package:motion_app/services/database.dart';

class ProfileWidget extends StatefulWidget {
  const ProfileWidget({Key? key}) : super(key: key);

  @override
  _ProfileWidgetState createState() => _ProfileWidgetState();
}

class _ProfileWidgetState extends State<ProfileWidget> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _currentPasswordController =
      TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();

  final User? user = FirebaseAuth.instance.currentUser;
  bool _isLoading = false;
  String? _errorMessage;
  String? _profileImageUrl;
  List<Project> _projects = []; // List to hold the user's projects

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _loadUserProjects(); // Load projects on initialization
  }

  Future<void> _loadUserData() async {
    setState(() {
      _isLoading = true;
    });
    try {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user!.uid)
          .get();
      String? displayName = userDoc['displayName'];

      if (displayName != null) {
        _nameController.text = displayName;
      }
    } catch (e) {
      setState(() {
        _errorMessage = "Failed to load user data.";
      });
    }
    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _loadUserProjects() async {
    try {
      // Query the projects collection to find projects by the user
      _projects =
          await DatabaseService(uid: user!.uid).getUserCompletedProjects();
    } catch (e) {
      print("Failed to load projects: $e");
    }
  }

  Future<void> _updateDisplayName() async {
    if (_nameController.text.isEmpty) {
      setState(() {
        _errorMessage = "Display name cannot be empty.";
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user!.uid)
          .update({'displayName': _nameController.text.trim()});

      setState(() {
        _errorMessage = "Display name updated successfully!";
      });
    } catch (e) {
      setState(() {
        _errorMessage = "Failed to update display name.";
      });
    }

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _changePassword() async {
    if (_newPasswordController.text.isEmpty ||
        _currentPasswordController.text.isEmpty) {
      setState(() {
        _errorMessage = "Please fill in all password fields.";
      });
      return;
    }

    try {
      // Re-authenticate the user
      final credential = EmailAuthProvider.credential(
        email: user!.email!,
        password: _currentPasswordController.text,
      );
      await user!.reauthenticateWithCredential(credential);

      // Update the password
      await user!.updatePassword(_newPasswordController.text);
      setState(() {
        _errorMessage = "Password updated successfully!";
      });
    } catch (e) {
      setState(() {
        _errorMessage = "Failed to update password. ${e.toString()}";
      });
    }
  }

  String _getUserInitials(String displayName) {
    List<String> names = displayName.split(" ");
    String initials = "";
    if (names.isNotEmpty) {
      initials = names[0][0];
      if (names.length > 1) {
        initials += names[1][0];
      }
    }
    return initials.toUpperCase();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Edit Profile',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.grey[800],
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (_isLoading) ...[
                const Center(child: CircularProgressIndicator()),
                const SizedBox(height: 20),
              ] else ...[
                CircleAvatar(
                  radius: 50,
                  backgroundImage: _profileImageUrl != null
                      ? NetworkImage(_profileImageUrl!)
                      : null,
                  backgroundColor: Colors.indigo[100],
                  child: _profileImageUrl == null
                      ? Text(
                          _getUserInitials(_nameController.text.isEmpty
                              ? 'User'
                              : _nameController.text),
                          style: const TextStyle(
                              fontSize: 40, color: Colors.indigo),
                        )
                      : null,
                ),
                const SizedBox(height: 10),
                Text(
                  user?.email ?? 'No Email',
                  style: const TextStyle(fontSize: 16, color: Colors.grey),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: 'Display Name',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _updateDisplayName,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.indigo[600],
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: const Text(
                    'Save',
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                const Text(
                  "Change Password",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                TextField(
                  controller: _currentPasswordController,
                  decoration: InputDecoration(
                    labelText: 'Current Password',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  obscureText: true,
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _newPasswordController,
                  decoration: InputDecoration(
                    labelText: 'New Password',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  obscureText: true,
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: _changePassword,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: const Text(
                    'Change Password',
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                // Achievements Section (Projects)
                const Text(
                  "Achievements",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                _projects.isEmpty
                    ? const Text("No achievements yet.")
                    : Column(
                        children: _projects.map((project) {
                          return Card(
                            margin: const EdgeInsets.symmetric(vertical: 8),
                            child: ListTile(
                              title: Text(project.title ),
                              subtitle:
                                  Text(project.description ),
                            ),
                          );
                        }).toList(),
                      ),
                const SizedBox(height: 30),
                const SizedBox(height: 10),
                if (_errorMessage != null)
                  Text(
                    _errorMessage!,
                    style: TextStyle(
                      color: _errorMessage ==
                                  "Display name updated successfully!" ||
                              _errorMessage == "Password updated successfully!"
                          ? Colors.green
                          : Colors.red,
                    ),
                  ),
              ]
            ],
          ),
        ),
      ),
    );
  }
}
