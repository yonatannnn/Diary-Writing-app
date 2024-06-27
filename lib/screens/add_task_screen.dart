import 'dart:ui';
import 'package:diary/screens/tasks.dart';
import 'package:diary/services/authService.dart';
import 'package:diary/services/notificationService.dart';
import 'package:diary/services/taskService.dart';
import 'package:diary/services/userService.dart';
import 'package:diary/widgets/Drawer.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:provider/provider.dart';

class AddTaskScreen extends StatefulWidget {
  const AddTaskScreen({super.key});

  @override
  _AddTaskScreenState createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends State<AddTaskScreen> {
  TextEditingController dateController = TextEditingController();
  TextEditingController timeController = TextEditingController();
  TextEditingController titleController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();

  final Taskservice noteService = Taskservice();
  final userService = UserService();
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  NotificationService notificationService = NotificationService();
  DateTime? selectedDate;
  TimeOfDay? selectedTime;

  String userEmail = 'Loading';

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    dateController.text = "${now.toLocal()}".split(' ')[0];
    final nowTime = TimeOfDay.now();
    timeController.text =
        "${nowTime.hour}:${nowTime.minute.toString().padLeft(2, '0')}";
    selectedDate = now;
    selectedTime = nowTime;
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      setState(() {
        userEmail = user.email ?? 'Email not available';
      });
    } else {
      setState(() {
        userEmail = 'No user signed in';
      });
    }
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

  Future<void> _scheduleNotification(String title, String body) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'your_channel_id',
      'Your channel name',
      importance: Importance.max,
      priority: Priority.high,
    );
    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);

    await flutterLocalNotificationsPlugin.show(
      0,
      title,
      body,
      platformChannelSpecifics,
      payload: 'item x',
    );
  }

  @override
  Widget build(BuildContext context) {
    print('new user email ${userEmail}');
    return Scaffold(
      appBar: AppBar(
        title: Text("Add Task"),
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
                                selectedDate = pickedDate;
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
                              initialTime: TimeOfDay.now(),
                            );

                            if (pickedTime != null) {
                              setState(() {
                                timeController.text =
                                    "${pickedTime.hour}:${pickedTime.minute.toString().padLeft(2, '0')}";
                                selectedTime = pickedTime;
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
                              final title = titleController.text;
                              final description = descriptionController.text;

                              if (isValidTitleController(title) &&
                                  isValidBodyController(description)) {
                                try {
                                  await Provider.of<Taskservice>(context,
                                          listen: false)
                                      .saveTaskToFirestore(
                                    selectedDate!,
                                    title,
                                    description,
                                    selectedTime!,
                                    userEmail,
                                  );

                                  // Schedule local notification
                                  await _scheduleNotification(
                                      title, description);

                                  showSnackBar(
                                      'Notification sent successfully!');
                                  showSnackBar("Task added successfully!",
                                      isSuccess: true);
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => Tasks(),
                                    ),
                                  );
                                } catch (e) {
                                  showSnackBar("Failed to add task: $e");
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
