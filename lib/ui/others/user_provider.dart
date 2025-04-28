import 'dart:developer';
import 'package:chat_app/core/models/user_models.dart';
import 'package:chat_app/core/services/database_service.dart';
import 'package:flutter/material.dart';

class UserProvider extends ChangeNotifier {
  final DatabaseService _db;

  UserProvider(this._db);

  UserModels? _currentUser;

  UserModels? get user => _currentUser;

  Future<void> loadUser(String uid) async {
    try {
      final userData = await _db.loadUser(uid);

      if (userData != null) {
        _currentUser = UserModels.fromMap(userData);
        log('User loaded successfully: ${_currentUser?.name}');
        if (_currentUser?.nameSearch != null) {
          log('User nameSearch: ${_currentUser?.nameSearch}');
        } else {
          log('User has no nameSearch field');
        }
        notifyListeners();
      } else {
        log('No user data found for UID: $uid');
      }
    } catch (e) {
      log('Error loading user: $e');
    }
  }

  Future<void> updateUser(UserModels updatedUser) async {
    try {
      if (updatedUser.uid == null) {
        throw Exception('User ID cannot be null');
      }

      await _db.saveUser(updatedUser.toMap());
      _currentUser = updatedUser;
      log('User updated successfully: ${_currentUser?.name}');
      notifyListeners();
    } catch (e) {
      log('Error updating user: $e');
      rethrow;
    }
  }

  void clearUser() {
    _currentUser = null;
    notifyListeners();
  }
}
