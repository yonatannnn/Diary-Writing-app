import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:diary/models/note_model.dart';
import 'package:flutter/foundation.dart';

class NoteService extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> saveNoteToFirestore(
    String date,
    String title,
    String body,
    String userEmail,
  ) async {
    try {
      String docId = '${userEmail}_${title}';

      await _firestore.collection('Notes').doc(docId).set({
        'date': date,
        'title': title,
        'body': body,
        'userEmail': userEmail,
      });

      print('Note data saved successfully!');
    } catch (e) {
      print('Error saving note data: $e');
      throw Exception(e);
    }
  }

  Stream<List<Note>> getNotes() {
    return _firestore.collection("Notes").snapshots().map((snapshot) =>
        snapshot.docs.map((doc) => Note.fromFirestore(doc)).toList());
  }
}
