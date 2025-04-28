import 'dart:developer';

import 'package:chat_app/core/enums/enums.dart';
import 'package:chat_app/core/models/user_models.dart';
import 'package:chat_app/core/other/base_viewmodel.dart';
import 'package:chat_app/core/services/database_service.dart';

class ChatListViewmodel extends BaseViewModel {
  final DatabaseService _db;
  final UserModels _currentUser;

  ChatListViewmodel(this._db, this._currentUser) {
    fetchUsers();
  }

  search(String value) {
    _filteredUsers =
        _users.where((e) => e.name!.toLowerCase().contains(value)).toList();
    notifyListeners();
  }

  List<UserModels> _users = [];
  List<UserModels> _filteredUsers = [];

  List<UserModels> get users => _users;
  List<UserModels> get filteredUsers => _filteredUsers;

  bool _isLoading = true;
  bool get isLoading => _isLoading;

  Future<void> fetchUsers() async {
    // if (!_isLoading) {
    //   _isLoading = true;
    //   notifyListeners();
    // }

    try {
      setState(ViewState.loading);
      //final res = await _db.fetchUsers(_currentUser.uid!);

      _db.fetchUserStream(_currentUser.uid!).listen((data) {
        _users = data.docs.map((e) => UserModels.fromMap(e.data())).toList();
        _filteredUsers = _users;
        notifyListeners();
      });

      // if (res != null) {
      //   _users = res.map((e) => UserModels.fromMap(e)).toList();
      //   _filteredUsers = _users;
      //   notifyListeners();
      // } else {
      //   _users = [];
      // }

      setState(ViewState.idle);
    } catch (e) {
      log('Error Fetching Users: $e');
      _users = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Add method to refresh users list
  Future<void> refreshUsers() async {
    await fetchUsers();
  }

  @override
  void dispose() {
    _users = [];
    super.dispose();
  }
}
