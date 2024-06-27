import 'package:diary/firebase_options.dart';
import 'package:diary/screens/add_note_screen.dart';
import 'package:diary/screens/add_task_screen.dart';
import 'package:diary/screens/home_screen.dart';
import 'package:diary/screens/login_screen.dart';
import 'package:diary/services/authService.dart';
import 'package:diary/services/noteService.dart';
import 'package:diary/services/notificationService.dart';
import 'package:diary/services/taskService.dart';
import 'package:diary/services/userService.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:provider/provider.dart';
import './widgets/welcome.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> saveStringToPreferences(String key, String value) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString(key, value);
}

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  String? fcmToken = await FirebaseMessaging.instance.getToken() ?? '';
  saveStringToPreferences('userToken', fcmToken);

  final apnsToken = await FirebaseMessaging.instance.getAPNSToken();

  NotificationService notificationService = NotificationService();
  await notificationService.configureFirebaseMessaging();

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  FirebaseMessaging messaging = FirebaseMessaging.instance;
  NotificationSettings settings = await messaging.requestPermission();
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher');
  final InitializationSettings initializationSettings =
      InitializationSettings(android: initializationSettingsAndroid);

  // Initialize the plugin with the settings
  await flutterLocalNotificationsPlugin.initialize(initializationSettings);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthService()),
        ChangeNotifierProvider(create: (_) => NoteService()),
        ChangeNotifierProvider(create: (_) => UserService()),
        ChangeNotifierProvider(create: (_) => Taskservice()),
        StreamProvider<User?>(
          create: (context) =>
              Provider.of<AuthService>(context, listen: false).userStream,
          initialData: null,
        ),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: CheckScreen(),
    );
  }
}

class CheckScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final user = Provider.of<User?>(context);
    if (user == null) {
      return LoginScreen();
    } else {
      return HomeScreen();
    }
  }
}
