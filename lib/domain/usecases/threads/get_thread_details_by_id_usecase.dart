import 'package:robin_ai/domain/entities/chat_message_class.dart';
import 'package:robin_ai/domain/entities/exceptions.dart';
import 'package:robin_ai/domain/entities/thread_class.dart';
import 'package:robin_ai/domain/interfaces/chat_repository_interface.dart';
import 'package:uuid/uuid.dart';

class GetThreadDetailsByIdUseCase {
  final IChatRepository chatRepository;

  GetThreadDetailsByIdUseCase({required this.chatRepository});

  Future<Thread> call({required String threadId}) async {
    try {
      return await chatRepository.getThreadDetailsById(threadId: threadId);
    } catch (e) {
      if (e is ThreadDetailsNotFoundException) {
        // If thread details not found, return a default Thread object with a "Hi!" message
        return Thread(id: Uuid().v4(), name: 'New Chat', messages: [
          ChatMessage(
              id: Uuid().v4(),
              content: 'Hi!',
              isUserMessage: false,
              timestamp: DateTime.now())
        ]);
      } else {
        // Re-throw the error if it's not a ThreadDetailsNotFoundException
        rethrow;
      }
    }
  }
}
