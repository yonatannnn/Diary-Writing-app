import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:diary/models/user_model.dart';
import 'package:flutter/material.dart';

class UserService extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> saveUserToFirestore(
    String email,
    String firstName,
    String lastName,
    String password,
  ) async {
    String newEmail = email.toLowerCase();
    try {
      await _firestore.collection('CustomUsers').doc(newEmail).set({
        'firstName': firstName,
        'lastName': lastName,
        'email': newEmail,
        'password': password,
      });
      print('User data saved successfully!');
    } catch (e) {
      print('Error saving user data: $e');
      throw Exception(e);
    }
  }

  Stream<List<User>> getUsers() {
    return _firestore.collection("CustomUsers").snapshots().map((snapshot) =>
        snapshot.docs.map((doc) => User.fromFirestore(doc)).toList());
  }

  Future<User?> getUserByEmail(String email) async {
    print('email ====== ${email}');
    try {
      DocumentSnapshot snapshot =
          await _firestore.collection('CustomUsers').doc(email).get();
      if (snapshot.exists) {
        return User.fromFirestore(snapshot);
      } else {
        return null;
      }
    } catch (e) {
      print('Error fetching user: $e');
      throw Exception(e);
    }
  }
}
