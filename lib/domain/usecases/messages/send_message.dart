import 'package:robin_ai/domain/entities/chat_message_class.dart';

import '../../../../data/repository/chat_repository.dart';
import '../../../../core/error_messages.dart';

class SendMessageUseCase {
  final ChatRepository chatRepository;

  SendMessageUseCase({required this.chatRepository});

  Future<ChatMessage> call(String threadId, ChatMessage message) async {
    try {
      final responseMessage = await chatRepository.sendChatMessage(
        threadId: threadId,
        message: message,
      );
      return responseMessage;
    } catch (e) {
      // Log the error or handle it appropriately
      print('Error sending message: $e');
      throw Exception(ErrorMessages.sendMessageFailed);
    }
  }
}
