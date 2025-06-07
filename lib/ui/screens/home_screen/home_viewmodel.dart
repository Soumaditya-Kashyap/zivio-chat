import 'dart:async';
import 'dart:developer';
import 'package:chat_app/core/enums/enums.dart';
import 'package:chat_app/core/models/user_models.dart';
import 'package:chat_app/core/other/base_viewmodel.dart';
import 'package:chat_app/core/services/database_service.dart';
import 'package:flutter/material.dart';

class HomeViewmodel extends BaseViewModel {
  final DatabaseService _db;
  final TextEditingController searchController = TextEditingController();
  String _searchQuery = '';
  List<UserModels> _searchResults = [];
  bool _isSearching = false;
  String? _currentUserId;
  Timer? _debounce;

  HomeViewmodel(this._db);

  List<UserModels> get searchResults => _searchResults;
  bool get isSearching => _isSearching;
  String get searchQuery => _searchQuery;

  void setCurrentUserId(String userId) {
    _currentUserId = userId;
  }

  void setSearchQuery(String query) {
    _searchQuery = query;

    // Cancel previous debounce timer
    if (_debounce?.isActive ?? false) _debounce!.cancel();

    // Don't search if query is empty
    if (query.isEmpty) {
      _searchResults = [];
      notifyListeners();
      return;
    }

    // Debounce the search
    _debounce = Timer(const Duration(milliseconds: 300), () {
      searchUsers();
    });

    notifyListeners();
  }

  Future<void> searchUsers() async {
    if (_searchQuery.isEmpty || _currentUserId == null) {
      _searchResults = [];
      notifyListeners();
      return;
    }

    try {
      _isSearching = true;
      notifyListeners();

      final results =
          await _db.searchUsersByName(_searchQuery, _currentUserId!);
      _searchResults = results.map((data) => UserModels.fromMap(data)).toList();

      _isSearching = false;
      notifyListeners();
    } catch (e) {
      log('Error searching users: $e');
      _searchResults = [];
      _isSearching = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    searchController.dispose();
    super.dispose();
  }
}
