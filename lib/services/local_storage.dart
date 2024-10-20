// import 'dart:convert';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:motion_app/models/project.dart';


// class LocalStorageService {
//   static const String _projectsKey = 'projects';

//   Future<List<Project>> loadProjects() async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     String? projectsString = prefs.getString(_projectsKey);

//     if (projectsString != null) {
//       try {
//         List<dynamic> projectList = jsonDecode(projectsString);
//         print('Decoded projectList: $projectList');

//         return projectList.map((dynamic project) {
//           if (project is Map<String, dynamic>) {
//             // Use a fallback for the ID, if it's missing
//             return Project(
//               id: project['id'] != null
//                   ? project['id'] as String
//                   : 'Unknown ID',
//               title: project['title'] as String? ?? 'No title',
//               description:
//                   project['description'] as String? ?? 'No description',
//             );
//           } else {
//             print('Project item is not a Map: $project');
//             throw Exception('Invalid project format');
//           }
//         }).toList();
//       } catch (e) {
//         print('Error loading projects: $e');
//         return [];
//       }
//     } else {
//       return [];
//     }
//   }

//   // Save a project to local storage
//   Future<void> saveProject(
//       Project project, List<Project> currentProjects) async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();

//     currentProjects.add(project);

//     // Convert the list of projects to a list of maps and store directly, not as encoded JSON strings
//     List<Map<String, String>> projectsMapList = currentProjects
//         .map((project) => {
//               'id': project.id,
//               'title': project.title,
//               'description': project.description,
//             })
//         .toList();

//     prefs.setString(
//         _projectsKey, jsonEncode(projectsMapList)); // Save as a JSON string
//   }

//   // Delete a project by index
//   Future<void> deleteProject(int index, List<Project> currentProjects) async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     currentProjects.removeAt(index);
//     List<String> projectsString = currentProjects
//         .map((project) => jsonEncode({
//               'title': project.title,
//               'description': project.description,
//             }))
//         .toList();
//     prefs.setString(_projectsKey, jsonEncode(projectsString));
//   }
// }
