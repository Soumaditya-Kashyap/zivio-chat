// ignore_for_file: avoid_print

import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final _auth = FirebaseAuth.instance;

  Future<User?> signup(String email, String password) async {
    try {
      final authCredential = await _auth.createUserWithEmailAndPassword(
          email: email, password: password);

      if (authCredential.user != null) {
        print('User Created Succesfully');
        return authCredential.user;
      }
    } on FirebaseAuthException catch (e) {
      print(e.message);
      rethrow;
    } catch (e) {
      print(e.toString());
      rethrow;
    }
    return null;
  }

  Future<User?> login(String email, String password) async {
    try {
      final authCredential = await _auth.signInWithEmailAndPassword(
          email: email, password: password);

      if (authCredential.user != null) {
        print('User loggedin successfully');
        return authCredential.user;
      }
    } on FirebaseAuthException catch (e) {
      print(e.message);
      rethrow;
    } catch (e) {
      print(e.toString());
      rethrow;
    }
    return null;
  }

  Future<void> logout() async {
    try {
      await _auth.signOut();
    } catch (e) {
      print(e.toString());
      rethrow;
    }
  }
}
