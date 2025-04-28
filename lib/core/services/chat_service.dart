import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:developer';

class ChatService {
  final _fire = FirebaseFirestore.instance;

  Future<void> saveMessage(
      Map<String, dynamic> message, String chatRoomId) async {
    try {
      await _fire
          .collection('chatRooms')
          .doc(chatRoomId)
          .collection('messages')
          .add(message);
    } catch (e) {
      log('Error saving message: $e');
      rethrow;
    }
  }

  Future<void> updateLastMessage(String senderUid, String receiverUid,
      String messageContent, int timestamp) async {
    try {
      // Handle self-chat case
      bool isSelfChat = senderUid == receiverUid;

      // Get sender and receiver data
      final senderData = await _fire.collection('users').doc(senderUid).get();

      // Only get receiver data if it's different from sender
      final receiverData = isSelfChat
          ? senderData
          : await _fire.collection('users').doc(receiverUid).get();

      if (!senderData.exists || !receiverData.exists) {
        throw Exception('User data not found');
      }

      // Create message info
      final messageInfo = {
        'content': messageContent,
        'timestamp': timestamp,
        'senderId': senderUid
      };

      // 1. Update sender's chat contacts with receiver info
      // In self-chat, we need special handling for the name
      var contactData = receiverData.data()!;

      // For self-chat, make sure the name has the special format
      if (isSelfChat && contactData['name'] != null) {
        // Only format if it doesn't already have the "Its Me" prefix
        String name = contactData['name'] as String;
        if (!name.startsWith("Its Me")) {
          contactData = {...contactData, 'name': "Its Me (${name})"};
        }
      }

      await _fire
          .collection('chatContacts')
          .doc(senderUid)
          .collection('contacts')
          .doc(receiverUid)
          .set(
              {
            ...contactData,
            'lastMessage': messageInfo,
            'unreadCounter': 0, // Sender always has 0 unread messages
          },
              SetOptions(
                  merge: true)); // Use merge to avoid overwriting existing data

      // 2. For non-self-chat, update receiver's contacts
      if (!isSelfChat) {
        DocumentReference receiverContactRef = _fire
            .collection('chatContacts')
            .doc(receiverUid)
            .collection('contacts')
            .doc(senderUid);

        // Check if this is an existing chat contact for the receiver
        DocumentSnapshot receiverContactDoc = await receiverContactRef.get();

        if (receiverContactDoc.exists) {
          // Existing contact - update last message and increment unread counter
          await receiverContactRef.update({
            'lastMessage': messageInfo,
            'unreadCounter': FieldValue.increment(1),
          });
        } else {
          // New contact - add sender as contact with unread counter = 1
          await receiverContactRef.set({
            ...senderData.data()!,
            'lastMessage': messageInfo,
            'unreadCounter': 1,
          });
        }
      }

      log('Updated chat contacts');
    } catch (e) {
      log('Error updating last message: $e');
      rethrow;
    }
  }

  Future<void> resetUnreadCounter(String userId, String contactId) async {
    try {
      await _fire
          .collection('chatContacts')
          .doc(userId)
          .collection('contacts')
          .doc(contactId)
          .update({
        'unreadCounter': 0,
      });
    } catch (e) {
      log('Error resetting unread counter: $e');
      rethrow;
    }
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> getMessages(String chatRoomId) {
    return _fire
        .collection('chatRooms')
        .doc(chatRoomId)
        .collection('messages')
        .orderBy('timestamp', descending: false)
        .snapshots();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> getChatContacts(String userId) {
    return _fire
        .collection('chatContacts')
        .doc(userId)
        .collection('contacts')
        .orderBy('lastMessage.timestamp', descending: true)
        .snapshots();
  }

  Future<bool> haveChatted(String userId, String contactId) async {
    try {
      final doc = await _fire
          .collection('chatContacts')
          .doc(userId)
          .collection('contacts')
          .doc(contactId)
          .get();

      return doc.exists;
    } catch (e) {
      log('Error checking chat history: $e');
      return false;
    }
  }

  // Delete a chat contact
  Future<void> deleteChatContact(String userId, String contactId) async {
    try {
      // Delete the contact from the user's contacts collection
      await _fire
          .collection('chatContacts')
          .doc(userId)
          .collection('contacts')
          .doc(contactId)
          .delete();

      log('Chat contact deleted successfully');
    } catch (e) {
      log('Error deleting chat contact: $e');
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
}
