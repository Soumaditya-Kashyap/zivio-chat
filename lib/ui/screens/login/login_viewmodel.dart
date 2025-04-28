//to manage the login screen state and logic
// ignore_for_file: avoid_print

import 'dart:developer';

import 'package:chat_app/core/enums/enums.dart';
import 'package:chat_app/core/other/base_viewmodel.dart';
import 'package:chat_app/core/services/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LoginViewmodel extends BaseViewModel {
  // ignore: unused_field
  final AuthService _auth;

  LoginViewmodel(this._auth);

  String _email = '';
  String _password = '';

  bool get isFormValid => _email.isNotEmpty && _password.isNotEmpty;

  void setEmail(String value) {
    _email = value.trim();
    notifyListeners();
  }

  void setPassword(String value) {
    _password = value.trim();
    notifyListeners();
  }

  Future<User?> login() async {
    setState(ViewState.loading);
    try {
      // Validate inputs
      if (_email.isEmpty) {
        throw Exception('Please enter your email');
      }

      if (_password.isEmpty) {
        throw Exception('Please enter your password');
      }

      final user = await _auth.login(_email, _password);
      setState(ViewState.idle);
      return user;
    } on FirebaseAuthException catch (e) {
      setState(ViewState.idle);
      log('FirebaseAuthException: ${e.code} - ${e.message}');
      rethrow;
    } catch (e) {
      log('Error during login: $e');
      setState(ViewState.idle);
      rethrow;
    }
  }
}
