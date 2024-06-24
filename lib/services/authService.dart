import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AuthService extends ChangeNotifier {
  final auth = FirebaseAuth.instance;
  User? _user;
  User? get user => _user;

  AuthService() {
    _init();
  }

  Future<void> _init() async {
    _user = auth.currentUser;
    notifyListeners();
  }

  Future<UserCredential> login(String email, password) async {
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
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      return user.email;
    } else {
      return null;
    }
  }

  Future<UserCredential> signup(String email, password) async {
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