import 'package:flutter/material.dart';
import 'package:motion_app/screens/home/invitations_list.dart';


class SettingsPage extends StatefulWidget {
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  

  @override
  Widget build(BuildContext context) {
    // Move the settingsOptions list into the build method
    List<Map<String, dynamic>> settingsOptions = [
      {
        'icon': Icons.person,
        'label': 'Profile',
        'action': () {
          // Action for Profile setting
          print("Profile clicked");
        }
      },
      {
        'icon': Icons.lock,
        'label': 'Privacy',
        'action': () {
          // Action for Privacy setting
          print("Privacy clicked");
        }
      },
      {
        'icon': Icons.notifications,
        'label': 'Notifications',
        'action': () {
          // Navigate to InvitationListWidget when Notifications is clicked
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => InvitationListWidget()),
          );
        }
      },
      {
        'icon': Icons.logout,
        'label': 'Log Out',
        'action': () async {
          // Action for Log
        }
      }
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings Page'),
      ),
      body: Container(
        color: Colors.grey[200], // Background color for the sidebar
        child: ListView(
          children: settingsOptions.map((setting) {
            return ListTile(
              leading: Icon(setting['icon'], color: Colors.black),
              title: Text(setting['label']),
              onTap: () {
                setting['action'](); // Trigger the action
              },
            );
          }).toList(),
        ),
      ),
    );
  }
}
