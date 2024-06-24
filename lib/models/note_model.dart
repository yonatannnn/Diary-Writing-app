import 'package:cloud_firestore/cloud_firestore.dart';

class Note {
  final String date;
  final String title;
  final String body;
  final String userEmail;
  final String time;

  Note(
      {required this.body,
      required this.title,
      required this.date,
      required this.time,
      required this.userEmail});

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'body': body,
      'date': date,
      'userEmail': userEmail,
      'time': time
    };
  }

  static Note fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Note(
        title: data['title'],
        body: data['body'],
        date: data['date'],
        userEmail: data['userEmail'],
        time: data['time']);
  }
}
