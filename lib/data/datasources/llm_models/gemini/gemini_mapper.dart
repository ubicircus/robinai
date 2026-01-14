import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:robin_ai/domain/entities/chat_message_class.dart';

class ChatMessageMapper {
  static List<Content> toGeminiFormat(List<ChatMessage> messages) {
    return messages.map((message) {
      if (message.isUserMessage) {
        return Content.text(message.content);
      } else {
        return Content.model([TextPart(message.content)]);
      }
    }).toList();
  }

  // static List<String> toListModel(List<GeminiModel> models) {
  //   return mapperFunction(models);
  // }

  // static List<String> mapperFunction(List<GeminiModel> models) {
  //   return models.map((model) => model.id).toList();
  // }
}
