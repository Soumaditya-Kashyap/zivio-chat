import 'dart:async';
import 'dart:developer';

import 'package:chat_app/core/models/message_model.dart';
import 'package:chat_app/core/models/user_models.dart';
import 'package:chat_app/core/other/base_viewmodel.dart';
import 'package:chat_app/core/services/chat_service.dart';
import 'package:flutter/material.dart';

class ChatViewmodel extends BaseViewModel {
  final ChatService _chatService;
  final UserModels _currentUser;
  final UserModels _receiver;

  StreamSubscription? _subscription;

  ChatViewmodel(
    this._chatService,
    this._currentUser,
    this._receiver,
  ) {
    getChatRoom();

    // Reset unread counter for current user when opening chat
    _chatService.resetUnreadCounter(_currentUser.uid!);

    _subscription = _chatService.getMessages(chatRoomId).listen((messages) {
      _messages = messages.docs.map((e) => Message.fromMap(e.data())).toList();
      // Sort messages by timestamp
      _messages.sort((a, b) => a.timestamp!.compareTo(b.timestamp!));
      notifyListeners();
    });
  }

  String chatRoomId = '';

  final _messageController = TextEditingController();
  TextEditingController get controller => _messageController;

  List<Message> _messages = [];

  List<Message> get messages => _messages;

  getChatRoom() {
    // Create a consistent chat room ID by comparing UIDs
    if (_currentUser.uid!.compareTo(_receiver.uid!) > 0) {
      chatRoomId = '${_currentUser.uid}_${_receiver.uid}';
    } else {
      chatRoomId = "${_receiver.uid}_${_currentUser.uid}";
    }
  }

  Future<void> saveMessage() async {
    log('Message Send');

    try {
      final now = DateTime.now();
      String content = _messageController.text.trim();

      if (content.isEmpty) {
        throw Exception('Please Enter Some Text');
      }

      final message = Message(
        id: now.millisecondsSinceEpoch.toString(),
        content: content,
        senderId: _currentUser.uid,
        receiverId: _receiver.uid,
        timestamp: now,
      );

      // Save the message to Firestore
      await _chatService.saveMessage(message.toMap(), chatRoomId);

      // Update last message for both users
      await _chatService.updateLastMessage(_currentUser.uid!, _receiver.uid!,
          content, now.millisecondsSinceEpoch);

      _messageController.clear();
    } catch (e) {
      log('Error sending message: $e');
      rethrow;
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    _subscription?.cancel();
    super.dispose();
  }
}
