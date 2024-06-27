import 'dart:ui';

import 'package:diary/models/task_model.dart';
import 'package:diary/screens/add_task_screen.dart';
import 'package:diary/screens/login_screen.dart';
import 'package:diary/services/authService.dart';
import 'package:diary/services/taskService.dart';
import 'package:diary/widgets/Drawer.dart';
import 'package:diary/widgets/single_task_widget.dart';
import 'package:diary/widgets/welcome.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class Tasks extends StatelessWidget {
  final Taskservice taskService = Taskservice();

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthService>(context);
    User? user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    String userEmail = user.email ?? 'Email not available';

    return Scaffold(
      appBar: AppBar(
        title: Text('Your Tasks',
            style:
                GoogleFonts.aBeeZee(fontSize: 20, fontWeight: FontWeight.bold)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () async {
              await authProvider.signOut();
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) => LoginScreen()),
              );
            },
          ),
        ],
      ),
      drawer: CustomDrawer(),
      body: Stack(
        children: [
          Container(
            width: double.infinity,
            height: double.infinity,
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Welcome(isDiary: false),
                    SizedBox(height: 20),
                    Expanded(
                      child: StreamBuilder<List<Task>>(
                        stream: taskService.getTasks(),
                        builder: (context, AsyncSnapshot<List<Task>> snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return Center(child: CircularProgressIndicator());
                          }
                          if (snapshot.hasError) {
                            return Center(
                                child: Text('Error: ${snapshot.error}'));
                          }
                          if (!snapshot.hasData || snapshot.data!.isEmpty) {
                            return Center(child: Text('No tasks available.'));
                          }

                          final userTasks = snapshot.data!
                              .where((task) => task.userEmail == userEmail)
                              .toList();

                          if (userTasks.isEmpty) {
                            return Center(
                                child: Text('No Tasks Found.',
                                    style: GoogleFonts.aBeeZee(
                                        color: Colors.white,
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold)));
                          }

                          return ListView.builder(
                            itemCount: userTasks.length,
                            itemBuilder: (context, index) {
                              return TaskWidget(
                                id: userTasks[index].id,
                                title: userTasks[index].title,
                                description: userTasks[index].description,
                                date: userTasks[index].date,
                                time: userTasks[index].time,
                                isChecked: userTasks[index].checked,
                                toggleChecked: (isChecked) {
                                  taskService.updateTaskCheckedStatus(
                                      userTasks[index].id, isChecked);
                                },
                              );
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddTaskScreen()),
          );
        },
        child: Icon(Icons.add),
        backgroundColor: Colors.blue,
      ),
    );
  }
}
