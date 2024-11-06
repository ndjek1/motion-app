import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ProfileWidget extends StatefulWidget {
  const ProfileWidget({Key? key}) : super(key: key);

  @override
  _ProfileWidgetState createState() => _ProfileWidgetState();
}

class _ProfileWidgetState extends State<ProfileWidget> {
  final TextEditingController _nameController = TextEditingController();
  final User? user = FirebaseAuth.instance.currentUser;
  bool _isLoading = false;
  String? _errorMessage;
  String? _profileImageUrl;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  // Load the current user data (display name and avatar URL) from Firestore
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

  // Update the display name in Firestore
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

  // Function to generate user initials if no profile image is available
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
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (_isLoading) ...[
              const Center(child: CircularProgressIndicator()),
              const SizedBox(height: 20),
            ] else ...[
              // Profile avatar
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
                        style:
                            const TextStyle(fontSize: 40, color: Colors.indigo),
                      )
                    : null,
              ),
              const SizedBox(height: 10),
              // User email display
              Text(
                user?.email ?? 'No Email',
                style: const TextStyle(fontSize: 16, color: Colors.grey),
              ),
              const SizedBox(height: 20),
              // Display name input field
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
              // Save button
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
                  )),
              const SizedBox(height: 10),
              // Display success or error message
              if (_errorMessage != null)
                Text(
                  _errorMessage!,
                  style: TextStyle(
                    color: _errorMessage == "Display name updated successfully!"
                        ? Colors.green
                        : Colors.red,
                  ),
                ),
            ]
          ],
        ),
      ),
    );
  }
}
