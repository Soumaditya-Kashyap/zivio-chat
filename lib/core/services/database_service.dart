import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseService {
  final _fire = FirebaseFirestore.instance;

  Future<void> saveUser(Map<String, dynamic> userData) async {
    try {
      await _fire.collection('users').doc(userData['uid']).set(userData);
      log('User Saved Succesfully');
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>?> loadUser(String uid) async {
    try {
      final res = await _fire.collection('users').doc(uid).get();
      if (res.data() != null) {
        log('User Loaded Successfully');
        return res.data();
      } else {
        log('No user data found');
        return null;
      }
    } catch (e) {
      log('Error loading user: $e');
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>?> fetchUsers(String currentUserId) async {
    try {
      final res = await _fire
          .collection('users')
          .where('uid', isNotEqualTo: currentUserId)
          .get();

      return res.docs.map((e) => e.data()).toList();
    } catch (e) {
      log('Error loading user: $e');
      rethrow;
    }
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> fetchUserStream(
          String currentUserId) =>
      _fire
          .collection('users')
          .where('uid', isNotEqualTo: currentUserId)
          .snapshots();
}
