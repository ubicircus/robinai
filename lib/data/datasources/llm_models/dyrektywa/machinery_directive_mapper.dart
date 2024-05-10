import 'package:robin_ai/domain/entities/chat_message_class.dart';

class ChatMessageMapper {
  /// Converts a list of ChatMessage objects into a format suitable for the backend.
  static List<Map<String, dynamic>> toJson(
      List<ChatMessage> conversationHistory) {
    return conversationHistory.map((chatMessage) {
      return {
        'human': chatMessage.isUserMessage ? chatMessage.content : null,
        'ai': !chatMessage.isUserMessage ? chatMessage.content : null,
      };
    }).toList();
  }
}
