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
      DocumentSnapshot docSnapshot =
          await _firestore.collection('Notes').doc(docId).get();

      if (docSnapshot.exists) {
        throw Exception('A note with the same title already exists.');
      }

      await _firestore.collection('Notes').doc(docId).set({
        'id': docId,
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

  Future<void> deleteNoteFromFirestore(String docId) async {
    try {
      await _firestore.collection('Notes').doc(docId).delete();
      print('Note deleted successfully!');
    } catch (e) {
      print('Error deleting note: $e');
      throw Exception('Error deleting note: $e');
    }
  }

  Future<void> updateNoteInFirestore(
    String id,
    String date,
    String title,
    String body,
    String userEmail,
  ) async {
    try {
      await _firestore.collection('Notes').doc(id).update({
        'date': date,
        'title': title,
        'body': body,
        'userEmail': userEmail,
      });

      print('Note data updated successfully!');
    } catch (e) {
      print('Error updating note data: $e');
      throw Exception(e);
    }
  }
}
