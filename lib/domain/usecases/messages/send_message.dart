import 'package:robin_ai/core/service_names.dart';
import 'package:robin_ai/domain/entities/chat_message_class.dart';

import '../../../data/repository/chat_message_repository.dart';
import '../../../../core/error_messages.dart';

class SendMessageUseCase {
  final ChatMessageRepository chatRepository;

  SendMessageUseCase({required this.chatRepository});

  Future<ChatMessage> call(
      String threadId,
      ChatMessage message,
      ServiceName serviceName,
      String modelName,
      List<ChatMessage> chatHistory) async {
    try {
      final responseMessage = await chatRepository.sendChatMessage(
        threadId: threadId,
        message: message,
        serviceName: serviceName,
        modelName: modelName,
        chatHistory: chatHistory,
      );
      return responseMessage;
    } catch (e) {
      // Log the error or handle it appropriately
      print('Error sending message: $e');
      throw Exception(ErrorMessages.sendMessageFailed);
    }
  }
}
