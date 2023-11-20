import '/domain/entities/chat_message_class.dart';
import '/data/repository/chat_repository.dart';

class FetchAllMessagesUseCase {
  final ChatRepository chatRepository;

  FetchAllMessagesUseCase({required this.chatRepository});

  Future<List<ChatMessageClass>> call() async {
    // The method sendChatMessage in the ChatRepository should return the response from the server
    final listOfMessages = await chatRepository.fetchChatMessages();

    // The returned message should be a ChatMessage object
    return listOfMessages;
  }
}
