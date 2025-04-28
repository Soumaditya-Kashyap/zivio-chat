import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseService {
  final _fire = FirebaseFirestore.instance;

  Future<void> saveUser(Map<String, dynamic> userData) async {
    try {
      await _fire.collection('users').doc(userData['uid']).set(userData);
      log('User Saved Successfully');
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

  Future<List<Map<String, dynamic>>?> fetchAllUsers(
      String currentUserId) async {
    try {
      final res = await _fire
          .collection('users')
          .where('uid', isNotEqualTo: currentUserId)
          .get();

      return res.docs.map((e) => e.data()).toList();
    } catch (e) {
      log('Error loading users: $e');
      rethrow;
    }
  }

  // Get only users that have had conversations with the current user
  Stream<QuerySnapshot<Map<String, dynamic>>> fetchChatContacts(
      String currentUserId) {
    return _fire
        .collection('chatContacts')
        .doc(currentUserId)
        .collection('contacts')
        .snapshots();
  }

  // Simple search users by name - more like Instagram
  Future<List<Map<String, dynamic>>> searchUsersByName(
      String query, String currentUserId) async {
    try {
      final queryLower = query.toLowerCase();

      // Get all users except current user
      final querySnapshot = await _fire
          .collection('users')
          .where('uid', isNotEqualTo: currentUserId)
          .get();

      // Filter results client-side by name (simpler approach)
      final results =
          querySnapshot.docs.map((doc) => doc.data()).where((userData) {
        final name = userData['name'] as String?;
        return name != null && name.toLowerCase().contains(queryLower);
      }).toList();

      return results;
    } catch (e) {
      log('Error searching users: $e');
      rethrow;
    }
  }

  // Add user to chat contacts when first message is sent
  Future<void> addUserToChatContacts(
      String currentUserId, Map<String, dynamic> contactData) async {
    try {
      await _fire
          .collection('chatContacts')
          .doc(currentUserId)
          .collection('contacts')
          .doc(contactData['uid'])
          .set(contactData);

      log('User added to chat contacts');
    } catch (e) {
      log('Error adding user to chat contacts: $e');
      rethrow;
    }
  }

  // Check if a user is in chat contacts
  Future<bool> isUserInChatContacts(
      String currentUserId, String contactUserId) async {
    try {
      final doc = await _fire
          .collection('chatContacts')
          .doc(currentUserId)
          .collection('contacts')
          .doc(contactUserId)
          .get();

      return doc.exists;
    } catch (e) {
      log('Error checking if user is in chat contacts: $e');
      rethrow;
    }
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> fetchUserStream(
      String currentUserId) {
    return _fire
        .collection('chatContacts')
        .doc(currentUserId)
        .collection('contacts')
        .snapshots();
  }
}
