import 'package:robin_ai/data/model/perplexity_message_model.dart';
import 'package:robin_ai/domain/entities/chat_message_class.dart';

class ChatMessageMapper {
  static List<PerplexityChatMessageModel> toModelFormat(
      List<ChatMessage> messages) {
    return messages.map((message) {
      return PerplexityChatMessageModel(
        role: message.isUserMessage
            ? PerplexityChatMessageRole.user
            : PerplexityChatMessageRole.assistant,
        content: PerplexityChatMessageContentItemModel.text(message.content),
      );
    }).toList();
  }
}
