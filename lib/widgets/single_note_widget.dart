import 'package:flutter/material.dart';
import 'package:diary/widgets/note_detail_screen.dart'; // Adjust import path as per your project

class NoteWidget extends StatelessWidget {
  final String id;
  final String title;
  final String body;
  final String date;
  final String email;

  const NoteWidget({
    Key? key,
    required this.email,
    required this.id,
    required this.title,
    required this.body,
    required this.date,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    String newTitle =
        title.substring(0, 1).toUpperCase() + title.substring(1).toLowerCase();
    return Container(
      height: MediaQuery.of(context).size.height * 0.3,
      width: MediaQuery.of(context).size.width * 0.45,
      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 8),
      child: Card(
        elevation: 3,
        color: Colors.black87.withOpacity(0.8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        child: ListTile(
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          title: Text(
            newTitle,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          subtitle: Text(
            '$date',
            style: TextStyle(
              color: Colors.white70,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => NoteDetailsScreen(
                  
                  id: id,
                  title: title,
                  body: body,
                  date: date,
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
