import 'package:flutter/material.dart';
import 'package:motion_app/services/auth.dart';

class HomeScreen extends StatelessWidget {
  HomeScreen({super.key});
  final AuthService _auth = AuthService();

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
              icon: const Icon(Icons.person,
                  color: Colors.white), // set icon color to white
              label: const Text(
                'Signout',
                style:
                    TextStyle(color: Colors.white), // set text color to white
              ),
              style: TextButton.styleFrom(
                foregroundColor:
                    Colors.white, // applies to both text and icon by default
              ),
              iconAlignment: IconAlignment.start, // your custom alignment
            ),
          ],
      ),
      body: Center(
        heightFactor: 2,
        child: ElevatedButton(
          onPressed: () {
            // When the button is pressed, navigate to the project creation screen.
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const NewProjectScreen()),
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue, // Button background color
            padding: const EdgeInsets.symmetric(
                horizontal: 50, vertical: 20), // Button size
            textStyle: const TextStyle(fontSize: 20), // Button text size
          ),
          child: const Text('+ New Project',
              style: TextStyle(color: Colors.white)),
        ),
      ),
    );
  }
}

class NewProjectScreen extends StatelessWidget {
  const NewProjectScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create New Project'),
      ),
      body: const Center(
        child: Text(
          'New Project Creation Form Goes Here!',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}
