import 'package:flutter/material.dart';

class NoteDetailsScreen extends StatelessWidget {
  final String id;
  final String title;
  final String body;
  final String date;

  const NoteDetailsScreen({
    Key? key,
    required this.id,
    required this.title,
    required this.body,
    required this.date,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Note Details'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Title: $title',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              'Date: $date',
              style: TextStyle(fontSize: 16, fontStyle: FontStyle.italic),
            ),
            SizedBox(height: 8),
            Text(
              'Body:\n$body',
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}