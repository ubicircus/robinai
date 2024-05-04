import 'package:dart_openai/dart_openai.dart';
import 'package:robin_ai/domain/entities/chat_message_class.dart';

class ChatMessageMapper {
  static List<OpenAIChatCompletionChoiceMessageModel> toModelFormat(
      List<ChatMessage> messages) {
    return messages.map((message) {
      return OpenAIChatCompletionChoiceMessageModel(
        content: [
          OpenAIChatCompletionChoiceMessageContentItemModel.text(
              message.content),
        ],
        role: message.isUserMessage
            ? OpenAIChatMessageRole.user
            : OpenAIChatMessageRole.assistant,
      );
    }).toList();
  }

  static List<String> toListModel(List<OpenAIModelModel> models) {
    return mapperFunction(models);
  }

  static List<String> mapperFunction(List<OpenAIModelModel> models) {
    return models.map((model) => model.id).toList();
  }
}
