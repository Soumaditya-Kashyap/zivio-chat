import 'dart:async';
import 'dart:developer';

import 'package:chat_app/core/enums/enums.dart';
import 'package:chat_app/core/models/user_models.dart';
import 'package:chat_app/core/other/base_viewmodel.dart';
import 'package:chat_app/core/services/database_service.dart';
import 'package:chat_app/core/services/chat_service.dart';
import 'package:flutter/material.dart';

class ChatListViewmodel extends BaseViewModel {
  final DatabaseService _db;
  final ChatService _chatService = ChatService();
  final UserModels _currentUser;
  StreamSubscription? _chatContactsStream;

  ChatListViewmodel(this._db, this._currentUser) {
    fetchChatContacts();
  }

  void search(String value) {
    if (value.isEmpty) {
      _filteredUsers = _users;
    } else {
      _filteredUsers = _users
          .where((e) =>
              e.name != null &&
              e.name!.toLowerCase().contains(value.toLowerCase()))
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

  Future<void> fetchChatContacts() async {
    if (_currentUser.uid == null) {
      log('Cannot fetch chat contacts: current user ID is null');
      _isLoading = false;
      notifyListeners();
      return;
    }

    try {
      setState(ViewState.loading);

      _chatContactsStream =
          _chatService.getChatContacts(_currentUser.uid!).listen((data) {
        _users = data.docs.map((e) => UserModels.fromMap(e.data())).toList();

        // Sort by last message timestamp (already ordered in the query)
        _filteredUsers = _users;

        if (_isLoading) {
          _isLoading = false;
          setState(ViewState.idle);
        } else {
          notifyListeners();
        }
      });
    } catch (e) {
      log('Error fetching chat contacts: $e');
      _users = [];
      _isLoading = false;
      setState(ViewState.idle);
    }
  }

  // Refresh the chat contacts list
  Future<void> refreshContacts() async {
    _isLoading = true;
    notifyListeners();
    await fetchChatContacts();
  }

  // Delete a chat contact
  Future<void> deleteChatContact(UserModels user) async {
    if (_currentUser.uid == null || user.uid == null) {
      log('Cannot delete chat contact: user ID is null');
      return;
    }

    try {
      setState(ViewState.loading);

      // Delete the contact
      await _chatService.deleteChatContact(_currentUser.uid!, user.uid!);

      // Refresh the contacts list
      await refreshContacts();

      setState(ViewState.idle);
    } catch (e) {
      log('Error deleting chat contact: $e');
      setState(ViewState.idle);
    }
  }

  @override
  void dispose() {
    _chatContactsStream?.cancel();
    super.dispose();
  }
}
