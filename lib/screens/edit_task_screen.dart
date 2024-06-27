import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:diary/services/authService.dart';
import 'package:diary/services/taskService.dart';
import 'package:diary/screens/tasks.dart';

class EditTaskScreen extends StatefulWidget {
  final DateTime date;
  final String title;
  final String description;
  final TimeOfDay time;
  final String id;

  const EditTaskScreen({
    required this.time,
    required this.title,
    required this.description,
    required this.date,
    required this.id,
    Key? key,
  }) : super(key: key);

  @override
  _EditTaskScreenState createState() => _EditTaskScreenState();
}

class _EditTaskScreenState extends State<EditTaskScreen> {
  late TextEditingController dateController;
  late TextEditingController titleController;
  late TextEditingController descriptionController;
  late TextEditingController timeController;
  final Taskservice taskService = Taskservice();

  @override
  void initState() {
    super.initState();
    dateController = TextEditingController(
      text: DateFormat('yyyy-MM-dd').format(widget.date),
    );

    timeController = TextEditingController(
      text:
          "${widget.time.hour}:${widget.time.minute.toString().padLeft(2, '0')}",
    );
    titleController = TextEditingController(text: widget.title);
    descriptionController = TextEditingController(text: widget.description);
  }

  bool isValidTitleController(String title) {
    return title.isNotEmpty;
  }

  bool isValidBodyController(String description) {
    return description.isNotEmpty;
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
    final authProvider = Provider.of<AuthService>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text("Edit Task" , style:
                GoogleFonts.aBeeZee(fontSize: 20, fontWeight: FontWeight.bold)),
        centerTitle: true,),
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
                              initialDate: widget.date,
                              firstDate: DateTime(2000),
                              lastDate: DateTime.now(),
                            );

                            if (pickedDate != null) {
                              setState(() {
                                dateController.text =
                                    DateFormat('yyyy-MM-dd').format(pickedDate);
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
                        GestureDetector(
                          onTap: () async {
                            TimeOfDay? pickedTime = await showTimePicker(
                              context: context,
                              initialTime: widget.time,
                            );

                            if (pickedTime != null) {
                              setState(() {
                                timeController.text =
                                    "${pickedTime.hour}:${pickedTime.minute.toString().padLeft(2, '0')}";
                              });
                            }
                          },
                          child: AbsorbPointer(
                            child: TextField(
                              controller: timeController,
                              readOnly: true,
                              style: TextStyle(color: Colors.white),
                              decoration: InputDecoration(
                                hintText: 'Time',
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
                          controller: descriptionController,
                          maxLines: 10,
                          style: TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            hintText: 'Description',
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
                              final userEmail = user?.email ?? '';

                              final title = titleController.text;
                              final description = descriptionController.text;

                              if (isValidTitleController(title) &&
                                  isValidBodyController(description)) {
                                try {
                                  await taskService.updateTaskInFirestore(
                                    widget.id,
                                    DateTime.parse(dateController.text),
                                    title,
                                    description,
                                    TimeOfDay(
                                      hour: int.parse(
                                          timeController.text.split(':')[0]),
                                      minute: int.parse(
                                          timeController.text.split(':')[1]),
                                    ),
                                    userEmail,
                                  );

                                  showSnackBar("Task updated successfully!",
                                      isSuccess: true);
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => Tasks(),
                                    ),
                                  );
                                } catch (e) {
                                  showSnackBar("Failed to update task: $e");
                                  print(e);
                                }
                              } else {
                                showSnackBar(
                                  'Please enter ${isValidTitleController(title) ? '' : 'title'}${isValidTitleController(title) && isValidBodyController(description) ? '' : ' and '}${isValidBodyController(description) ? '' : 'description'}.',
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
