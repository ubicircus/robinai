import '../../domain/entities/chat_message_class.dart';
import 'chat_message_network_model.dart';
import 'package:uuid/uuid.dart';

class ChatMessageMapper {
  static final _uuid = Uuid();

  static ChatMessageNetworkModel toNetworkModel(ChatMessage message) {
    return ChatMessageNetworkModel(
      id: message.id,
      content: message.content,
      timestamp: message.timestamp,
    );
  }

  static ChatMessage fromNetworkModel(ChatMessageNetworkModel networkModel) {
    return ChatMessage(
      id: networkModel.id,
      isUserMessage:
          false, // from network response is always from model not from user
      content: networkModel.content,
      timestamp: networkModel.timestamp,
    );
  }

  static ChatMessageNetworkModel fromNetworkResponse(dynamic response) {
    return ChatMessageNetworkModel(
      content: response, // Assuming `response` is just the message text.
      id: _uuid.v1(), // Reusing the UUID instance
      timestamp: DateTime.now(),
      // additional fields can be adjusted based on actual response structure
    );
  }
}
