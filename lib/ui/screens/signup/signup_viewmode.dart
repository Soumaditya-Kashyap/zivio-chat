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

  void setName(String value) {
    _name = value;
    notifyListeners();
    log("Name : $_name");
  }

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

  void setConfirmPassword(String value) {
    _confirmPassword = value;
    notifyListeners();
    log("Confirm_Password : $_confirmPassword ");
  }

  signup() async {
    setState(ViewState.loading);
    try {
      if (_password != _confirmPassword) {
        throw Exception('The passwords Do not Matched');
      }
      final res = await _auth.signup(_email, _password);

      if (res != null) {
        UserModels user = UserModels(
          uid: res.uid,
          name: _name,
          email: _email,
        );
        await _db.saveUser(user.toMap());
      }

      setState(ViewState.idle);
      // ignore: unused_catch_clause
    } on FirebaseException catch (e) {
      setState(ViewState.idle);
      rethrow;
    } catch (e) {
      log(e.toString());
      setState(ViewState.idle);
      rethrow;
    }
  }
}
