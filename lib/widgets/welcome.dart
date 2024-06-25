import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:diary/models/user_model.dart';
import 'package:diary/services/authService.dart';
import 'package:diary/services/userService.dart';

class Welcome extends StatelessWidget {
  const Welcome({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    final userService = Provider.of<UserService>(context);
    final user = authService.user;

    return FutureBuilder<User?>(
      future: user != null ? userService.getUserByEmail(user.email!) : null,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator();
        }
        
        if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        }
        print(user);
        final userData = snapshot.data;

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
              'These are your Diaries',
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
