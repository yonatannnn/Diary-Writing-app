import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:diary/models/user_model.dart'
    as userModel; // Alias the User model
import 'package:diary/services/authService.dart';
import 'package:diary/services/userService.dart';

class Welcome extends StatelessWidget {
  final bool isDiary;

  Welcome({super.key, required this.isDiary});

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    final userService = Provider.of<UserService>(context);
    final user = FirebaseAuth.instance.currentUser;

    return FutureBuilder<userModel.User?>(
      future: user != null ? userService.getUserByEmail(user.email!) : null,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        final userData = snapshot.data;
        String taskOrDiary = isDiary ? 'Diaries' : 'Tasks';
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              userData != null ? 'Hi, ${userData.firstName}' : 'Loading...',
              style: TextStyle(
                fontSize: 24,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 10),
            Text(
              'These are your $taskOrDiary',
              style: TextStyle(
                fontSize: 18,
                color: Color.fromARGB(255, 254, 252, 252),
              ),
            ),
          ],
        );
      },
    );
  }
}
