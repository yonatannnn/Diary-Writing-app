import 'dart:convert';
import 'dart:io';
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
import 'package:google_fonts/google_fonts.dart';
import 'package:googleapis_auth/auth_io.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';

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

  final Taskservice taskService = Taskservice();
  final UserService userService = UserService();
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  NotificationService notificationService = NotificationService();
  DateTime? selectedDate;
  TimeOfDay? selectedTime;

  String userEmail = 'Loading';
  String? fcmToken;

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
    // Retrieve FCM token from SharedPreferences
    retrieveFCMToken();
  }

  // Function to retrieve FCM token from SharedPreferences
  void retrieveFCMToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      fcmToken = prefs.getString('userToken');
    });
  }

  bool isValidTitleController(String title) {
    return title.isNotEmpty;
  }

  bool isValidBodyController(String description) {
    return description.isNotEmpty;
  }

  void showSnackBar(String message, {bool isSuccess = false}) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isSuccess ? Colors.green : Colors.red,
      ),
    );
  }

  Future<void> _scheduleNotification(String title, String body,
      DateTime selectedDate, TimeOfDay selectedTime) async {
    final now = DateTime.now();

    DateTime scheduledDateTime = DateTime(
      selectedDate.year,
      selectedDate.month,
      selectedDate.day,
      selectedTime.hour,
      selectedTime.minute,
    );

    int secondsUntilNotification = scheduledDateTime.difference(now).inSeconds;
    if (secondsUntilNotification > 86400) {
      DateTime dayBeforeNotificationTime =
          scheduledDateTime.subtract(Duration(days: 1));
      await _scheduleSingleNotification(
          'Reminder (1 day before)', title, body, dayBeforeNotificationTime);

      // Send push notification 1 day before
      await sendPushNotification(
          title: 'Reminder (1 day before)',
          body: '$title: $body',
          selectedDate: dayBeforeNotificationTime,
          selectedTime: selectedTime);
    }
    if (secondsUntilNotification > 600) {
      DateTime tenMinutesBeforeNotificationTime =
          scheduledDateTime.subtract(Duration(minutes: 10));
      await _scheduleSingleNotification('Reminder (10 min before)', title, body,
          tenMinutesBeforeNotificationTime);

      await sendPushNotification(
          title: 'Reminder (10 min before)',
          body: '$title: $body',
          selectedDate: tenMinutesBeforeNotificationTime,
          selectedTime: selectedTime);
    }

    await _scheduleSingleNotification(
        'Reminder', title, body, scheduledDateTime);

    await sendPushNotification(
        title: 'Reminder',
        body: '$title: $body',
        selectedDate: scheduledDateTime,
        selectedTime: selectedTime);
  }

  Future<void> _scheduleSingleNotification(String notificationTitle,
      String title, String body, DateTime notificationTime) async {
    final now = DateTime.now();
    int secondsUntilNotification = notificationTime.difference(now).inSeconds;

    if (secondsUntilNotification < 0) {
      secondsUntilNotification = 0;
    }

    await Future.delayed(Duration(seconds: secondsUntilNotification));

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
      notificationTitle,
      body,
      platformChannelSpecifics,
      payload: 'item x',
    );
  }

  Future<void> sendPushNotification(
      {required String title,
      required String body,
      required DateTime selectedDate,
      required TimeOfDay selectedTime}) async {
    final now = DateTime.now();
    final currentTime = TimeOfDay.now();
    DateTime scheduledDateTime = DateTime(
      selectedDate.year,
      selectedDate.month,
      selectedDate.day,
      selectedTime.hour,
      selectedTime.minute,
    );
    int secondsUntilNotification = scheduledDateTime.difference(now).inSeconds;
    if (secondsUntilNotification < 0) {
      secondsUntilNotification = 0;
    }
    await Future.delayed(Duration(seconds: secondsUntilNotification));

    if (fcmToken == null) {
      print('FCM token not available');
      return;
    }

    //serviceAccountJson here with 3

    final serviceAccount =
        ServiceAccountCredentials.fromJson(serviceAccountJson);

    final scopes = ['https://www.googleapis.com/auth/firebase.messaging'];

    final client = await clientViaServiceAccount(serviceAccount, scopes);

    final url = Uri.parse(
        'https://fcm.googleapis.com/v1/projects/diary-app-8d5de/messages:send');

    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer ${client.credentials.accessToken.data}',
    };

    final payload = jsonEncode({
      'message': {
        'token': fcmToken,
        'notification': {
          'title': title,
          'body': body,
        },
      },
    });

    try {
      final response = await http.post(
        url,
        headers: headers,
        body: payload,
      );

      if (response.statusCode == 200) {
        print('Push notification sent successfully');
      } else {
        print('Failed to send push notification: ${response.statusCode}');
        print('Response body: ${response.body}');
      }
    } catch (e) {
      print('Error sending push notification: $e');
    } finally {
      client.close();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Add Task",
            style:
                GoogleFonts.aBeeZee(fontSize: 20, fontWeight: FontWeight.bold)),
        centerTitle: true,
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
                              firstDate: DateTime.now(),
                              lastDate: DateTime(2100),
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
                                  showSnackBar("Task added successfully!",
                                      isSuccess: true);
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => Tasks(),
                                    ),
                                  );
                                  await _scheduleNotification('Reminder', title,
                                      selectedDate!, selectedTime!);

                                  await sendPushNotification(
                                    selectedTime: selectedTime!,
                                    selectedDate: selectedDate!,
                                    title: 'Reminder',
                                    body: title,
                                  );
                                  showSnackBar("Task added successfully!",
                                      isSuccess: true);
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
