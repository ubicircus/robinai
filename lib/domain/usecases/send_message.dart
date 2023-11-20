import '/domain/entities/chat_message_class.dart';
import '/data/repository/chat_repository.dart';

class SendMessageUseCase {
  final ChatRepository chatRepository;

  SendMessageUseCase({required this.chatRepository});

  Future<ChatMessageClass> call(ChatMessageClass message) async {
    // The method sendChatMessage in the ChatRepository should return the response from the server
    final responseMessage = await chatRepository.sendChatMessage(message);

    // The returned message should be a ChatMessage object
    return responseMessage;
  }
}
