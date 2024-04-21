// message_mapper.dart

// library or similar object based on your implementation
// import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:robin_ai/domain/entities/chat_message_class.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:robin_ai/domain/entities/user_class.dart';
import 'package:uuid/uuid.dart';

class MessageMapper {
  // Convert UI TextMessage to domain ChatMessage
  static ChatMessage textMessageToChatMessage(types.TextMessage textMessage) {
    return ChatMessage(
      id: textMessage.id,
      content: textMessage.text,
      isUserMessage:
          true, // conversion from textmessage to chatmessage is always a user message
      timestamp: DateTime.fromMillisecondsSinceEpoch(
          textMessage.createdAt ?? DateTime.now().millisecondsSinceEpoch),
    );
  }

  // Convert domain ChatMessage to UI TextMessage
  static types.TextMessage chatMessageToTextMessage(ChatMessage chatMessage) {
    return types.TextMessage(
      author: types.User(id: ''),
      // This needs to be your User object corresponding to the message
      id: chatMessage.id,
      text: chatMessage.content,
      createdAt: chatMessage.timestamp.millisecondsSinceEpoch,
    );
  }
}
