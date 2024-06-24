import 'package:cloud_firestore/cloud_firestore.dart';

class Note {
  final String date;
  final String title;
  final String body;
  final String userEmail;
  final String id;

  Note(
      {required this.id,
      required this.body,
      required this.title,
      required this.date,
      required this.userEmail});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'body': body,
      'date': date,
      'userEmail': userEmail,
    };
  }

  static Note fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Note(
        id: data['id'],
        title: data['title'],
        body: data['body'],
        date: data['date'],
        userEmail: data['userEmail']);
  }
}
