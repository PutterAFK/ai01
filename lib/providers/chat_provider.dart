import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:mindmate/models/conversation_model.dart';
import 'package:mindmate/models/message_model.dart';

import 'package:mindmate/services/database_service.dart';
import 'package:mindmate/services/ai_service.dart';

class ChatProvider extends ChangeNotifier {
  final DatabaseService _dbService = DatabaseService();
  final AIService _aiService = AIService();

  final List<MessageModel> _messages = [];
  List<MessageModel> get messages => _messages;

  List<ConversationModel> _conversations = [];
  List<ConversationModel> get conversations => _conversations;

  String? _currentConversationId;
  String? get currentConversationId => _currentConversationId;

  bool _isTyping = false;
  bool get isTyping => _isTyping;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  // =========================
  // USER ID
  // =========================

  String get userId {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return "guest_user";
    }

    return user.uid;
  }

  // =========================
  // LOAD CONVERSATIONS
  // =========================

  void loadConversations() {
    _dbService.getConversations(userId).listen(
      (List<ConversationModel> conversations) {
        _conversations = conversations;
        notifyListeners();
      },
    );
  }

  // =========================
  // START CHAT
  // =========================

  Future<void> startNewChat() async {
    _isLoading = true;
    notifyListeners();

    try {
      final id = await _dbService.createConversation(
        userId,
        'แชทใหม่',
      );

      _currentConversationId = id;

      _messages.clear();
    } catch (e) {
      debugPrint("startNewChat error: $e");
    }

    _isLoading = false;
    notifyListeners();
  }

  // =========================
  // OPEN CONVERSATION
  // =========================

  Future<void> openConversation(
    String conversationId,
  ) async {
    _currentConversationId = conversationId;

    _messages.clear();

    notifyListeners();

    _dbService
        .getMessages(
          userId: userId,
          conversationId: conversationId,
        )
        .listen(
      (List<MessageModel> messages) {
        _messages.clear();
        _messages.addAll(messages);

        notifyListeners();
      },
    );
  }

  // =========================
  // DELETE CONVERSATION
  // =========================

  Future<void> deleteConversation(
    String conversationId,
  ) async {
    await _dbService.deleteConversation(
      userId,
      conversationId,
    );

    if (_currentConversationId == conversationId) {
      _currentConversationId = null;

      _messages.clear();

      notifyListeners();
    }
  }

  // =========================
  // SEND MESSAGE
  // =========================

  Future<void> sendMessage(
    String content,
  ) async {
    if (content.trim().isEmpty) {
      return;
    }

    try {
      // สร้าง chat ใหม่อัตโนมัติ
      if (_currentConversationId == null) {
        await startNewChat();
      }

      final conversationId = _currentConversationId!;

      // =========================
      // USER MESSAGE
      // =========================

      final userMessage = MessageModel(
        id: DateTime.now()
            .millisecondsSinceEpoch
            .toString(),

        content: content.trim(),

        role: 'user',

        timestamp: DateTime.now(),

        conversationId: conversationId,
      );

      _messages.add(userMessage);

      notifyListeners();

      await _dbService.saveMessage(
        userId: userId,
        conversationId: conversationId,
        message: userMessage,
      );

      // =========================
      // UPDATE CONVERSATION
      // =========================

      final isFirstMessage =
          _messages.length <= 1;

      await _dbService.updateConversation(
        userId: userId,
        conversationId: conversationId,
        lastMessage: content.trim(),

        title: isFirstMessage
            ? content.trim().substring(
                0,
                content.trim().length > 30
                    ? 30
                    : content.trim().length,
              )
            : null,
      );

      // =========================
      // TYPING
      // =========================

      _isTyping = true;

      notifyListeners();

      // =========================
      // AI REQUEST
      // =========================

      String botReply = "";

      try {
        botReply =
            await _aiService.sendMessage(
          message: content,
          userId: userId,
        );
      } catch (e) {
        botReply =
            "⚠️ เกิดข้อผิดพลาด: $e";
      }

      // =========================
      // BOT MESSAGE
      // =========================

      final botMessage = MessageModel(
        id: DateTime.now()
            .millisecondsSinceEpoch
            .toString(),

        content: botReply,

        role: 'bot',

        timestamp: DateTime.now(),

        conversationId: conversationId,
      );

      _messages.add(botMessage);

      _isTyping = false;

      notifyListeners();

      await _dbService.saveMessage(
        userId: userId,
        conversationId: conversationId,
        message: botMessage,
      );

      await _dbService.updateConversation(
        userId: userId,
        conversationId: conversationId,
        lastMessage: botReply,
      );
    } catch (e) {
      debugPrint("sendMessage error: $e");

      _isTyping = false;

      notifyListeners();
    }
  }
}