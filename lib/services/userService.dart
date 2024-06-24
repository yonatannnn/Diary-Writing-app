import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:diary/models/user_model.dart';

class UserService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> saveUserToFirestore(
    String email,
    String firstName,
    String lastName,
    String password,
  ) async {
    try {
      await _firestore.collection('CustomUsers').doc(email).set({
        'firstName': firstName,
        'lastName': lastName,
        'email': email,
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
}
