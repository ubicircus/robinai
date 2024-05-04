import 'package:robin_ai/data/repository/thread_repository.dart';
import 'package:robin_ai/domain/entities/thread_class.dart';

class GetLastThreadIdUseCase {
  final ThreadRepository repository;

  GetLastThreadIdUseCase({required this.repository});

  Future<String> call() async {
    try {
      final List<Thread> threads = await repository
          .fetchAllThreads(); // Implement fetchAllThreads method in the repository
      if (threads.isNotEmpty) {
        // Get the last threadId
        return threads.last.id;
      } else {
        return ""; // Return empty string if no threads exist
      }
    } catch (e) {
      throw Exception("Failed to retrieve last threadId");
    }
  }
}
