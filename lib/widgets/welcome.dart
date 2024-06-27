import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:diary/models/user_model.dart'
    as userModel; 
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
        String taskOrDiary = isDiary ? 'Notes' : 'Tasks';
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(userData != null ? 'Hi, ${userData.firstName}' : 'Loading...',
                style: GoogleFonts.aBeeZee(
                    fontSize: 25,
                    color: Colors.white,
                    fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            Text('These are your $taskOrDiary',
                style: GoogleFonts.aBeeZee(
                  fontSize: 15,
                  color: Colors.white,
                )),
          ],
        );
      },
    );
  }
}
