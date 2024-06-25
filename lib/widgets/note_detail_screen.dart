import 'dart:ui';
import 'package:diary/models/note_model.dart';
import 'package:diary/models/user_model.dart';
import 'package:diary/screens/edit_note_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:diary/services/noteService.dart';

class NoteDetailsScreen extends StatelessWidget {
  final String id;
  final String title;
  final String body;
  final String date;

  const NoteDetailsScreen({
    Key? key,
    required this.id,
    required this.title,
    required this.body,
    required this.date,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<User?>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('Note Details'),
      ),
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/loginbg.png'),
                fit: BoxFit.cover,
              ),
            ),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
              child: Container(
                color: Colors.black.withOpacity(0.5),
              ),
            ),
          ),
          Center(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: double.infinity,
                    margin: const EdgeInsets.all(30),
                    padding: const EdgeInsets.all(30),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: Colors.white.withOpacity(0.2),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: 10),
                        Text(
                          date,
                          style: TextStyle(
                            fontSize: 16,
                            fontStyle: FontStyle.italic,
                            color: Colors.white70,
                          ),
                        ),
                        SizedBox(height: 20),
                        Text(
                          body,
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          // Navigate to edit note screen
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => EditNoteScreen(
                                id: id,
                                title: title,
                                body: body,
                                date: date,
                              ),
                            ),
                          );
                        },
                        child: Text('Edit'),
                      ),
                      SizedBox(width: 20),
                      ElevatedButton(
                        onPressed: () async {
                          try {
                            await context
                                .read<NoteService>()
                                .deleteNoteFromFirestore(id);
                            Navigator.pop(
                                context); // Navigate back after deleting
                          } catch (e) {
                            print('Error deleting note: $e');
                            // Optionally, show a snackbar or alert to the user
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Error deleting note: $e'),
                              ),
                            );
                          }
                        },
                        child: Text('Delete'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
