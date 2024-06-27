import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:diary/models/note_model.dart'; // Ensure this import points to your Note model
import 'package:diary/models/task_model.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class Taskservice extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> saveTaskToFirestore(
    DateTime date,
    String title,
    String description,
    TimeOfDay time,
    String userEmail,
  ) async {
    try {
      String docId = '${userEmail}_${title}_${description}';
      DocumentSnapshot docSnapshot =
          await _firestore.collection('Tasks').doc(docId).get();

      if (docSnapshot.exists) {
        throw Exception('A task with the same title already exists.');
      }

      await _firestore.collection('Tasks').doc(docId).set({
        'id': docId,
        'date': date,
        'title': title,
        'body': description,
        'time': {
          'hour': time.hour,
          'minute': time.minute,
        },
        'userEmail': userEmail,
        'checked': false
      });

      print('Note data saved successfully!');
    } catch (e) {
      print('Error saving note data: $e');
      throw Exception(e);
    }
  }

  Stream<List<Task>> getTasks() {
    return _firestore.collection("Tasks").snapshots().map((snapshot) =>
        snapshot.docs.map((doc) => Task.fromFirestore(doc)).toList());
  }

  Future<void> deleteTaskFromFirestore(String docId) async {
    try {
      await _firestore.collection('Tasks').doc(docId).delete();
      print('Task deleted successfully!');
    } catch (e) {
      print('Error deleting task: $e');
      throw Exception('Error deleting task: $e');
    }
  }

  Future<void> updateTaskInFirestore(
    String id,
    DateTime date,
    String title,
    String decription,
    TimeOfDay time,
    String userEmail,
  ) async {
    try {
      await _firestore.collection('Tasks').doc(id).update({
        'date': date,
        'title': title,
        'description': decription,
        'time': time,
        'userEmail': userEmail,
      });

      print('Note data updated successfully!');
    } catch (e) {
      print('Error updating note data: $e');
      throw Exception(e);
    }
  }

  Future<void> updateTaskCheckedStatus(String taskId, bool isChecked) async {
    try {
      await _firestore.collection('Tasks').doc(taskId).update({
        'checked': isChecked,
      });
      print('Task checked status updated successfully!');
    } catch (e) {
      print('Error updating task checked status: $e');
      throw Exception(e);
    }
  }


}
