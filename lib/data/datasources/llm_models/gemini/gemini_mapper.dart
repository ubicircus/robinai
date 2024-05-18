import 'package:flutter_gemini/flutter_gemini.dart';
import 'package:robin_ai/domain/entities/chat_message_class.dart';

class ChatMessageMapper {
  static List<Content> toGeminiFormat(List<ChatMessage> messages) {
    return messages.map((message) {
      return Content(
        parts: [Parts(text: message.content)],
        role: message.isUserMessage ? 'user' : 'model',
      );
    }).toList();
  }

  // static List<String> toListModel(List<GeminiModel> models) {
  //   return mapperFunction(models);
  // }

  // static List<String> mapperFunction(List<GeminiModel> models) {
  //   return models.map((model) => model.id).toList();
  // }
}
