import 'package:robin_ai/domain/entities/chat_message_class.dart';
import 'package:robin_ai/data/model/thread_model.dart';

class MessageMapper {
  static ChatMessage toDomain(Message message) {
    return ChatMessage(
      id: message.messageID,
      content: message.content,
      isUserMessage: message.isUserMessage,
      timestamp: message.timestamp,
      uiComponents: message.uiComponents,
    );
  }

  static Message fromDomain(ChatMessage chatMessage) {
    return Message(
      messageID: chatMessage.id,
      content: chatMessage.content,
      isUserMessage: chatMessage.isUserMessage,
      timestamp: chatMessage.timestamp,
      uiComponents: chatMessage.uiComponents,
    );
  }
}
