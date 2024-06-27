import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class Task {
  final String id;
  final String title;
  final String description;
  final TimeOfDay time;
  final DateTime date;
  final String userEmail;
  bool checked;

  Task({
    this.checked = false,
    required this.id,
    required this.userEmail,
    required this.title,
    required this.description,
    required this.time,
    required this.date,
  });

  factory Task.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Task(
      checked: data['checked'] ?? false,
      id: data['id'] ?? '',
      userEmail: data['userEmail'] ?? '',
      title: data['title'] ?? '',
      description: data['body'] ?? '',
      time: TimeOfDay(
        hour: data['time']['hour'] ?? 0,
        minute: data['time']['minute'] ?? 0,
      ),
      date: data['date'] != null
          ? (data['date'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }
}
