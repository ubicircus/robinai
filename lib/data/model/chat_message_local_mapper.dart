import 'package:robin_ai/data/model/thread_model.dart';

import '../../domain/entities/chat_message_class.dart';

class ChatMessageLocalMapper {
  static Message toLocalModel(ChatMessage message) {
    return Message(
      messageID: message.id,
      content: message.content,
      isUserMessage: message.isUserMessage,
      timestamp: message.timestamp,
    );
  }

  static ChatMessage fromLocalModel(Message localModel) {
    return ChatMessage(
      id: localModel.messageID,
      content: localModel.content,
      isUserMessage: localModel.isUserMessage,
      timestamp: localModel.timestamp,
    );
  }
}
