import 'dart:async';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:mindmate/models/conversation_model.dart';
import 'package:mindmate/models/message_model.dart';

import 'package:mindmate/services/database_service.dart';
import 'package:mindmate/services/ai_service.dart';

class ChatProvider
    extends ChangeNotifier {

  final DatabaseService
      _dbService =
      DatabaseService();

  final AIService
      _aiService =
      AIService();

  final List<MessageModel>
      _messages = [];

  List<MessageModel>
      get messages =>
          _messages;

  List<ConversationModel>
      _conversations = [];

  List<ConversationModel>
      get conversations =>
          _conversations;

  String?
      _currentConversationId;

  String?
      get currentConversationId =>
          _currentConversationId;

  bool _isTyping =
      false;

  bool get isTyping =>
      _isTyping;

  bool _isLoading =
      false;

  bool get isLoading =>
      _isLoading;

  StreamSubscription?
      _messageSubscription;

  String?
      get _userId =>
          FirebaseAuth
              .instance
              .currentUser
              ?.uid;

  /* LOAD CHAT LIST */
  void loadConversations() {

    if (
        _userId ==
            null) {
      return;
    }

    _dbService
        .getConversations(
          _userId!,
        )
        .listen(
      (
        data,
      ) {

        _conversations =
            data;

        notifyListeners();

      },
    );

  }

  /* CREATE CHAT */
  Future<void>
      startNewChat() async {

    if (
        _userId ==
            null) {
      return;
    }

    _isLoading =
        true;

    notifyListeners();

    try {

      final id =
          await _dbService
              .createConversation(
        _userId!,
        "แชทใหม่",
      );

      await openConversation(
        id,
      );

    } finally {

      _isLoading =
          false;

      notifyListeners();

    }

  }

  /* OPEN CHAT */
  Future<void>
      openConversation(
    String id,
  ) async {

    if (
        _userId ==
            null) {
      return;
    }

    await _messageSubscription
        ?.cancel();

    _currentConversationId =
        id;

    _messages.clear();

    notifyListeners();

    _messageSubscription =
        _dbService
            .getMessages(
      userId:
          _userId!,
      conversationId:
          id,
    ).listen(

      (
        data,
      ) {

        _messages
          ..clear()
          ..addAll(
            data,
          );

        notifyListeners();

      },

    );

  }

  /* SEND MESSAGE */
  Future<void>
      sendMessage(
    String content,
  ) async {

    if (
        content
            .trim()
            .isEmpty) {
      return;
    }

    if (
        _userId ==
            null) {
      return;
    }

    if (
        _currentConversationId ==
            null) {

      await startNewChat();

    }

    final chatId =
        _currentConversationId!;

    final userMessage =
        MessageModel(

      id:
          DateTime
              .now()
              .millisecondsSinceEpoch
              .toString(),

      content:
          content.trim(),

      role:
          "user",

      timestamp:
          DateTime.now(),

      conversationId:
          chatId,

    );

    await _dbService
        .saveMessage(

      userId:
          _userId!,

      conversationId:
          chatId,

      message:
          userMessage,

    );

    _isTyping =
        true;

    notifyListeners();

    String botReply;

    try {

      botReply =
          await _aiService
              .sendMessage(

        message:
            content,

        userId:
            _userId!,

      );

    } catch (_) {

      botReply =
          "ตอนนี้ระบบตอบกลับไม่ได้ ลองใหม่อีกครั้งนะ";

    }

    final botMessage =
        MessageModel(

      id:
          DateTime
              .now()
              .millisecondsSinceEpoch
              .toString(),

      content:
          botReply,

      role:
          "bot",

      timestamp:
          DateTime.now(),

      conversationId:
          chatId,

    );

    await _dbService
        .saveMessage(

      userId:
          _userId!,

      conversationId:
          chatId,

      message:
          botMessage,

    );

    _isTyping =
        false;

    notifyListeners();

  }

  /* FEEDBACK */
  Future<void>
      sendFeedback({

    required String
        question,

    required String
        reply,

    required int
        rating,

  }) async {

    if (
        _userId ==
            null) {
      return;
    }

    await _aiService
        .sendFeedback(

      question:
          question,

      reply:
          reply,

      rating:
          rating,

      userId:
          _userId!,

    );

  }

  @override
  void dispose() {

    _messageSubscription
        ?.cancel();

    super.dispose();

  }

}
