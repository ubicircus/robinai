import '../../domain/entities/chat_message_class.dart';
import 'chat_message_local_model.dart';

class ChatMessageLocalMapper {
  static ChatMessageLocal toLocalModel(ChatMessage message) {
    return ChatMessageLocal(
      id: message.id,
      content: message.content,
      timestamp: message.timestamp,
      isUserMessage: message.isUserMessage,
    );
  }

  static ChatMessage fromLocalModel(ChatMessageLocal networkModel) {
    return ChatMessage(
      id: networkModel.id,
      isUserMessage: networkModel.isUserMessage,
      content: networkModel.content,
      timestamp: networkModel.timestamp,
    );
  }

//   static ChatMessageLocal fromLocalResponse(dynamic response) {
//     return ChatMessageLocal(
//       content: response, // Assuming `response` is just the message text.
//       id: _uuid.v1(), // Reusing the UUID instance
//       timestamp: DateTime.now(),
//       isUserMessage: response
//     );
//   }
}
