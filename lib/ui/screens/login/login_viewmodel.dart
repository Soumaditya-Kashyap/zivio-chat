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

  void setEmail(String value) {
    _email = value;
    notifyListeners();
    log("Email : $_email");
  }

  void setPassword(String value) {
    _password = value;
    notifyListeners();
    log("Password : $_password");
  }

  Future<User?> login() async {
    setState(ViewState.loading);
    try {
      final user = await _auth.login(_email, _password);
      setState(ViewState.idle);
      return user;
    } on FirebaseException catch (e) {
      setState(ViewState.idle);
      rethrow;
    } catch (e) {
      print(e.toString());
      setState(ViewState.idle);
      rethrow;
    }
  }
}
