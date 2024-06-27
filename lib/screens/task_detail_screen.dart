import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:diary/models/note_model.dart'; // Update this to import Task model if needed
import 'package:diary/services/taskService.dart';
import 'package:diary/screens/edit_task_screen.dart';

class TaskDetailsScreen extends StatelessWidget {
  final String id;
  final String title;
  final String description;
  final DateTime date;
  final TimeOfDay time;

  const TaskDetailsScreen({
    Key? key,
    required this.time,
    required this.id,
    required this.title,
    required this.description,
    required this.date,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final taskService = Provider.of<Taskservice>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Task Details',
            style:
                GoogleFonts.aBeeZee(fontSize: 20, fontWeight: FontWeight.bold)),
        centerTitle: true,
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
                          date.toString(),
                          style: TextStyle(
                            fontSize: 16,
                            fontStyle: FontStyle.italic,
                            color: Colors.white70,
                          ),
                        ),
                        SizedBox(height: 20),
                        Text(
                          description,
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(width: 20),
                      ElevatedButton(
                        onPressed: () async {
                          try {
                            await taskService.deleteTaskFromFirestore(id);
                            Navigator.pop(context);
                          } catch (e) {
                            print('Error deleting task: $e');
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Error deleting task: $e'),
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
