import 'dart:ui';
import 'package:diary/screens/add_note_screen.dart';
import 'package:diary/screens/login_screen.dart';
import 'package:diary/services/authService.dart';
import 'package:diary/services/noteService.dart';
import 'package:diary/services/notificationService.dart';
import 'package:diary/services/userService.dart';
import 'package:diary/widgets/Drawer.dart';
import 'package:diary/widgets/single_note_widget.dart';
import 'package:diary/widgets/welcome.dart';
import 'package:flutter/material.dart';
import 'package:diary/models/note_model.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeScreen extends StatelessWidget {
  final NoteService noteService = NoteService();
  final userService = UserService();
  final notification = NotificationService();

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthService>(context);
    final user = Provider.of<User?>(context);
    if (user == null) {
      return Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    notification.saveToken();
    return Scaffold(
      appBar: AppBar(
        title: Text('Home Page',
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
                    Welcome(isDiary: true),
                    SizedBox(height: 20),
                    Expanded(
                      child: StreamBuilder<List<Note>>(
                        stream: noteService.getNotes(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return Center(child: CircularProgressIndicator());
                          }
                          if (snapshot.hasError) {
                            return Center(
                                child: Text('Error: ${snapshot.error}'));
                          }
                          if (!snapshot.hasData || snapshot.data!.isEmpty) {
                            return Center(
                                child: Text('No Notes Found.',
                                    style: GoogleFonts.aBeeZee(
                                        color: Colors.white,
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold)));
                          }

                          final userNotes = snapshot.data!.where((note) {
                            if (note.id != null) {
                              List<String> parts = note.id.split('_');
                              print('${parts[0]} == ${user.email}');
                              return parts.length >= 2 &&
                                  parts[0] == user.email;
                            }
                            return false;
                          }).toList();

                          if (userNotes.isEmpty) {
                            return Center(
                                child: Text('No Notes Found.',
                                    style: GoogleFonts.aBeeZee(
                                        color: Colors.white,
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold)));
                          }

                          return SingleChildScrollView(
                            child: GridView.builder(
                              physics: NeverScrollableScrollPhysics(),
                              shrinkWrap: true,
                              gridDelegate:
                                  SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                crossAxisSpacing: 10.0,
                                mainAxisSpacing: 10.0,
                                childAspectRatio: 0.75,
                              ),
                              itemCount: userNotes.length,
                              itemBuilder: (context, index) {
                                return NoteWidget(
                                  email: userNotes[index].userEmail,
                                  id: userNotes[index].id,
                                  title: userNotes[index].title,
                                  body: userNotes[index].body,
                                  date: userNotes[index].date,
                                );
                              },
                            ),
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
            MaterialPageRoute(builder: (context) => AddNoteScreen()),
          );
        },
        child: Icon(Icons.add),
        backgroundColor: Colors.blue,
      ),
    );
  }
}
