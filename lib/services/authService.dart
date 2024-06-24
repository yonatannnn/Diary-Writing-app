import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AuthService extends ChangeNotifier {
  final auth = FirebaseAuth.instance;
  User? _user;
  Stream<User?> get userStream => auth.authStateChanges(); // Stream of the user

  AuthService() {
    _init();
  }

  Future<void> _init() async {
    _user = auth.currentUser; 
    notifyListeners();
  }

  User? get user => _user;

  Future<UserCredential> login(String email, String password) async {
    try {
      UserCredential uc = await auth.signInWithEmailAndPassword(
          email: email, password: password);
      _user = uc.user;
      notifyListeners();
      return uc;
    } on FirebaseAuthException catch (e) {
      throw Exception(e.code);
    }
  }

  Future<void> signOut() async {
    await auth.signOut();
    _user = null;
    notifyListeners();
  }

  Future<String?> getCurrentUserEmail() async {
    User? user = auth.currentUser;
    return user?.email;
  }

  Future<UserCredential> signup(String email, String password) async {
    try {
      UserCredential uc = await auth.createUserWithEmailAndPassword(
          email: email, password: password);
      _user = uc.user;
      notifyListeners();
      return uc;
    } on FirebaseAuthException catch (e) {
      throw Exception(e.code);
    }
  }
}
