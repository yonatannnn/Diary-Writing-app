import 'package:diary/firebase_options.dart';
import 'package:diary/screens/add_note_screen.dart';
import 'package:diary/screens/home_screen.dart';
import 'package:diary/screens/login_screen.dart';
import 'package:diary/services/authService.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(
    ChangeNotifierProvider(
      create: (context) => AuthService(),
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
  const CheckScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthService>(context);
    print(authProvider.user);
    if (authProvider.user == null) {
      return LoginScreen();
    } else {
      return AddNoteScreen();
    }
  }
}
