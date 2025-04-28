import 'package:cloud_firestore/cloud_firestore.dart';

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
      rethrow;
    }
  }

  Future<void> updateLastMessage(String currentUid, String receiverUid,
      String message, int timestamp) async {
    try {
      // Update sender's last message
      await _fire.collection('users').doc(currentUid).update({
        'lastMessage': {
          "content": message,
          'timestamp': timestamp,
          'senderId': currentUid,
        },
      });

      // Update receiver's last message and increment unread counter
      await _fire.collection('users').doc(receiverUid).update({
        'lastMessage': {
          "content": message,
          'timestamp': timestamp,
          'senderId': currentUid,
        },
        "unreadCounter": FieldValue.increment(1)
      });
    } catch (e) {
      rethrow;
    }
  }

  Future<void> resetUnreadCounter(String userId) async {
    try {
      await _fire.collection('users').doc(userId).update({
        "unreadCounter": 0,
      });
    } catch (e) {
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
}
