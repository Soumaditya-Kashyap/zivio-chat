import 'dart:async';
import 'dart:developer';

import 'package:chat_app/core/enums/enums.dart';
import 'package:chat_app/core/models/user_models.dart';
import 'package:chat_app/core/other/base_viewmodel.dart';
import 'package:chat_app/core/services/database_service.dart';
import 'package:flutter/material.dart';

class ChatListViewmodel extends BaseViewModel {
  final DatabaseService _db;
  final UserModels _currentUser;
  StreamSubscription? _userStream;

  ChatListViewmodel(this._db, this._currentUser) {
    fetchUsers();
  }

  void search(String value) {
    if (value.isEmpty) {
      _filteredUsers = _users;
    } else {
      _filteredUsers = _users
          .where((e) => e.name!.toLowerCase().contains(value.toLowerCase()))
          .toList();
    }
    notifyListeners();
  }

  List<UserModels> _users = [];
  List<UserModels> _filteredUsers = [];

  List<UserModels> get users => _users;
  List<UserModels> get filteredUsers => _filteredUsers;

  bool _isLoading = true;
  bool get isLoading => _isLoading;

  Future<void> fetchUsers() async {
    try {
      setState(ViewState.loading);

      _userStream = _db.fetchUserStream(_currentUser.uid!).listen((data) {
        _users = data.docs.map((e) => UserModels.fromMap(e.data())).toList();

        // Sort users by last message timestamp if available
        _users.sort((a, b) {
          if (a.lastMessage == null && b.lastMessage == null) return 0;
          if (a.lastMessage == null) return 1;
          if (b.lastMessage == null) return -1;

          return (b.lastMessage!['timestamp'] as int)
              .compareTo(a.lastMessage!['timestamp'] as int);
        });

        _filteredUsers = _users;

        if (_isLoading) {
          _isLoading = false;
          setState(ViewState.idle);
        } else {
          notifyListeners();
        }
      });
    } catch (e) {
      log('Error Fetching Users: $e');
      _users = [];
      _isLoading = false;
      setState(ViewState.idle); // Changed from error to idle
    }
  }

  // Add method to refresh users list
  Future<void> refreshUsers() async {
    _isLoading = true;
    notifyListeners();
    await fetchUsers();
  }

  @override
  void dispose() {
    _userStream?.cancel();
    super.dispose();
  }
}
