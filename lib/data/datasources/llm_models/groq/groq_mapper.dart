import 'package:robin_ai/data/model/groq_message_model.dart';
import 'package:robin_ai/domain/entities/chat_message_class.dart';

class ChatMessageMapper {
  static List<GroqChatMessageModel> toModelFormat(List<ChatMessage> messages) {
    return messages.map((message) {
      return GroqChatMessageModel(
        role: message.isUserMessage
            ? GroqChatMessageRole.user
            : GroqChatMessageRole.assistant,
        content: GroqChatMessageContentItemModel.text(message.content),
      );
    }).toList();
  }
}
