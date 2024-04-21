import 'dart:async';

import '../../domain/entities/chat_message_class.dart';

abstract class IChatRepository {
  Future<ChatMessage> sendChatMessage(ChatMessage message);

  // Future<List<ChatMessage>> fetchChatMessages();
}
