import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AuthService extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  User? _user;
  User? get user => _user;
  Stream<User?> get userStream => _auth.authStateChanges();

  AuthService._(); // Private constructor for singleton pattern
  static final AuthService _instance = AuthService._();
  factory AuthService() => _instance;

  Future<void> _init() async {
    _user = _auth.currentUser;
    notifyListeners();
  }

  Future<UserCredential> login(String email, String password) async {
    try {
      UserCredential uc = await _auth.signInWithEmailAndPassword(
          email: email, password: password);
      _user = uc.user;
      notifyListeners();
      print('User logged in: ${_user?.email}');
      return uc;
    } on FirebaseAuthException catch (e) {
      throw Exception(e.code);
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
    _user = null;
    notifyListeners();
  }

  Future<String?> getCurrentUserEmail() async {
    User? user = _auth.currentUser;
    return user?.email;
  }

  Future<UserCredential> signup(String email, String password) async {
    try {
      UserCredential uc = await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
      _user = uc.user;
      notifyListeners();
      return uc;
    } on FirebaseAuthException catch (e) {
      throw Exception(e.code);
    }
  }
}
