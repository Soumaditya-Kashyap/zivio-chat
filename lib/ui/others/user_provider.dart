import 'package:chat_app/core/models/user_models.dart';
import 'package:chat_app/core/services/database_service.dart';
import 'package:flutter/material.dart';

class UserProvider extends ChangeNotifier {
  final DatabaseService _db;

  UserProvider(this._db);

  UserModels? _currentUser;

  UserModels? get user => _currentUser;

  Future<void> loadUser(String uid) async {
    final userData = await _db.loadUser(uid);

    if (userData != null) {
      _currentUser = UserModels.fromMap(userData);
      notifyListeners();
    }
  }

  clearUser() {
    _currentUser = null;
    notifyListeners();
  }
}
