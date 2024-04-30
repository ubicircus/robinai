import 'package:robin_ai/data/repository/chat_repository.dart';
import 'package:robin_ai/domain/entities/thread_class.dart';

class GetThreadListUseCase {
  final ChatRepository repository;

  GetThreadListUseCase({required this.repository});

  Future<List<Thread>> call() async {
    try {
      final List<Thread> threads = await repository
          .fetchAllThreads(); // Implement fetchAllThreads method in the repository

      return threads;
    } catch (e) {
      throw Exception("Failed to retrieve last threadId");
    }
  }
}
