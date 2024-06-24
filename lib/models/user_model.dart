import 'package:cloud_firestore/cloud_firestore.dart';

class User {
  final String firstName;
  final String lastName;
  final String email;
  final String password;

  User({
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.password,
  });

  Map<String, dynamic> toMap() {
    return {
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'password': password,
    };
  }

  static User fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return User(
      email: data['email'],
      firstName: data['firstName'],
      lastName: data['lastName'],
      password: data['password'],
    );
  }
}
