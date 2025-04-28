//used to store the state of signup screen
import 'dart:developer';
import 'package:chat_app/core/enums/enums.dart';
import 'package:chat_app/core/models/user_models.dart';
import 'package:chat_app/core/other/base_viewmodel.dart';
import 'package:chat_app/core/services/auth_service.dart';
import 'package:chat_app/core/services/database_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SignupViewmodel extends BaseViewModel {
  final AuthService _auth;
  final DatabaseService _db;

  SignupViewmodel(this._auth, this._db);

  String _name = '';
  String _email = '';
  String _password = '';
  String _confirmPassword = '';

  bool get isFormValid =>
      _name.isNotEmpty &&
      _email.isNotEmpty &&
      _password.isNotEmpty &&
      _confirmPassword.isNotEmpty &&
      _password == _confirmPassword;

  void setName(String value) {
    _name = value.trim();
    notifyListeners();
  }

  void setEmail(String value) {
    _email = value.trim();
    notifyListeners();
  }

  void setPassword(String value) {
    _password = value.trim();
    notifyListeners();
  }

  void setConfirmPassword(String value) {
    _confirmPassword = value.trim();
    notifyListeners();
  }

  Future<void> signup() async {
    setState(ViewState.loading);
    try {
      // Validate inputs
      if (_name.isEmpty) {
        throw Exception('Please enter your name');
      }

      if (_email.isEmpty) {
        throw Exception('Please enter your email');
      }

      if (_password.isEmpty) {
        throw Exception('Please enter a password');
      }

      if (_password.length < 6) {
        throw Exception('Password must be at least 6 characters');
      }

      if (_password != _confirmPassword) {
        throw Exception('Passwords do not match');
      }

      // Create user in Firebase Auth
      final res = await _auth.signup(_email, _password);

      if (res != null) {
        // Create user profile in Firestore
        UserModels user = UserModels(
          uid: res.uid,
          name: _name,
          email: _email,
          imageUrl: '',
          unreadCounter: 0,
        );
        await _db.saveUser(user.toMap());
        log('User created and saved to database: ${user.name}');
      }

      setState(ViewState.idle);
    } on FirebaseAuthException catch (e) {
      setState(ViewState.idle);
      log('FirebaseAuthException: ${e.code} - ${e.message}');
      rethrow;
    } catch (e) {
      log('Error during signup: $e');
      setState(ViewState.idle);
      rethrow;
    }
  }
}
