import 'dart:ui';
import 'package:diary/screens/home_screen.dart';
import 'package:diary/services/authService.dart';
import 'package:diary/services/noteService.dart';
import 'package:diary/widgets/Drawer.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';

class EditNoteScreen extends StatefulWidget {
  final String date;
  final String title;
  final String body;
  final String id;

  const EditNoteScreen({
    required this.title,
    required this.body,
    required this.date,
    required this.id,
    Key? key,
  }) : super(key: key);

  @override
  _EditNoteScreenState createState() => _EditNoteScreenState();
}

class _EditNoteScreenState extends State<EditNoteScreen> {
  late TextEditingController dateController;
  late TextEditingController titleController;
  late TextEditingController bodyController;
  final NoteService noteService = NoteService();

  @override
  void initState() {
    super.initState();
    dateController = TextEditingController(text: widget.date);
    titleController = TextEditingController(text: widget.title);
    bodyController = TextEditingController(text: widget.body);
  }

  bool isValidTitleController(String title) {
    return title.isNotEmpty;
  }

  bool isValidBodyController(String body) {
    return body.isNotEmpty;
  }

  void showSnackBar(String message, {bool isSuccess = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isSuccess ? Colors.green : Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<User?>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text("Edit Note"),
      ),
      drawer: CustomDrawer(),
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
              filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
              child: Container(
                color: Colors.black.withOpacity(0.3),
                padding: EdgeInsets.all(25),
                child: Center(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        GestureDetector(
                          onTap: () async {
                            DateTime? pickedDate = await showDatePicker(
                              context: context,
                              initialDate: DateTime.now(),
                              firstDate: DateTime(2000),
                              lastDate: DateTime.now(),
                            );

                            if (pickedDate != null) {
                              setState(() {
                                dateController.text =
                                    "${pickedDate.toLocal()}".split(' ')[0];
                              });
                            }
                          },
                          child: AbsorbPointer(
                            child: TextField(
                              controller: dateController,
                              readOnly: true,
                              style: TextStyle(color: Colors.white),
                              decoration: InputDecoration(
                                hintText: 'Date',
                                hintStyle: TextStyle(color: Colors.white),
                                filled: true,
                                fillColor: Colors.white.withOpacity(0.2),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide.none,
                                ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 10),
                        TextField(
                          controller: titleController,
                          style: TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            hintText: 'Title',
                            hintStyle: TextStyle(color: Colors.white),
                            filled: true,
                            fillColor: Colors.white.withOpacity(0.2),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                        SizedBox(height: 10),
                        TextField(
                          controller: bodyController,
                          maxLines: 10,
                          style: TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            hintText: 'Body',
                            hintStyle: TextStyle(color: Colors.white),
                            filled: true,
                            fillColor: Colors.white.withOpacity(0.2),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                        SizedBox(height: 20),
                        Center(
                          child: ElevatedButton(
                            onPressed: () async {
                              final authProvider = Provider.of<AuthService>(
                                  context,
                                  listen: false);
                              final userEmail = user?.email ?? '';
                              final title = titleController.text;
                              final body = bodyController.text;

                              if (isValidTitleController(title) &&
                                  isValidBodyController(body)) {
                                try {
                                  await noteService.updateNoteInFirestore(
                                    widget.id,
                                    dateController.text,
                                    title,
                                    body,
                                    userEmail,
                                  );

                                  showSnackBar("Note updated successfully!",
                                      isSuccess: true);
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => HomeScreen(),
                                    ),
                                  );
                                } catch (e) {
                                  showSnackBar("Failed to update note: $e");
                                }
                              } else {
                                showSnackBar(
                                  'Please enter ${isValidTitleController(title) ? '' : 'title'}${isValidTitleController(title) && isValidBodyController(body) ? '' : ' and '}${isValidBodyController(body) ? '' : 'body'}.',
                                );
                              }
                            },
                            child: Text("Save"),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
