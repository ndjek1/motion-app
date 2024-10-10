import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:motion_app/models/project.dart';
import 'package:motion_app/services/database.dart';
import 'package:uuid/uuid.dart';

class CommentScreen extends StatefulWidget {
  final String projectId; // The project for which the comments are displayed
  const CommentScreen({required this.projectId, Key? key}) : super(key: key);

  @override
  _CommentScreenState createState() => _CommentScreenState();
}

class _CommentScreenState extends State<CommentScreen> {
  final TextEditingController _commentController = TextEditingController();
  bool _isButtonEnabled = false; // Controls button visibility
  User? user = FirebaseAuth.instance.currentUser;
  final Uuid _uuid = Uuid(); // Initialize UUID generator

  @override
  void initState() {
    super.initState();
    _commentController.addListener(_onCommentChanged); // Listen for input changes
  }

  @override
  void dispose() {
    _commentController.dispose(); // Dispose the controller when done
    super.dispose();
  }

  // Enable or disable button based on text input
  void _onCommentChanged() {
    setState(() {
      _isButtonEnabled = _commentController.text.isNotEmpty;
    });
  }

  // Fetch comments from Firestore
  Stream<List<Comment>> _fetchComments() {
    
    return DatabaseService(uid: user!.uid).getProjectComments(widget.projectId);
  }

  // Add a new comment to Firestore
  Future<void> _addComment() async {
    if (_commentController.text.isEmpty) return;

    await DatabaseService(uid: user!.uid).updateProjectComments(
      _uuid.v4(),
      _commentController.text.trim(),
      user!.uid,
      widget.projectId,
      DateTime.now(),
    );

    _commentController.clear(); // Clear the text field after sending

    setState(() {
      // Trigger a rebuild after the comment is added
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Comments'),
        backgroundColor: Colors.indigo[600],
      ),
      body: Column(
        children: [
          // Display comments in a ListView
          Expanded(
            child: StreamBuilder<List<Comment>>(
              stream: _fetchComments(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return const Center(child: Text('Error loading comments.'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('No comments yet.'));
                }

                List<Comment> comments = snapshot.data!;
                return ListView.builder(
                  itemCount: comments.length,
                  itemBuilder: (context, index) {
                    Comment comment = comments[index];
                    return _buildCommentTile(comment);
                  },
                );
              },
            ),
          ),
          // Comment input field and button
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _commentController,
                    decoration: InputDecoration(
                      hintText: 'Enter your comment',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    maxLines: null, // Allows multi-line input
                  ),
                ),
                const SizedBox(width: 8),
                // Button is only enabled if there's input
                ElevatedButton(
                  onPressed: _isButtonEnabled ? _addComment : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.indigo[600],
                    disabledBackgroundColor: Colors.grey,
                  ),
                  child: const Text('Send'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Build a tile for each comment, showing the author and content
  Widget _buildCommentTile(Comment comment) {
    return FutureBuilder<String?>(
      future: DatabaseService(uid: user!.uid).getUserNameById(comment.userId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const ListTile(
            title: Text('Loading...'),
          );
        } else if (snapshot.hasError || !snapshot.hasData) {
          return ListTile(
            title: Text(comment.content),
            subtitle: const Text('Unknown user'),
            isThreeLine: true,
          );
        } else {
          String? displayName = snapshot.data;

          return ListTile(
            title: Text(comment.content),
            subtitle: Text('by $displayName at ${comment.createdAt}'),
            isThreeLine: true,
          );
        }
      },
    );
  }
}
