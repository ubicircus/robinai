import 'package:robin_ai/domain/entities/thread_class.dart';

abstract class IThreadRepository {
  Future<List<Thread>> fetchAllThreads();

  Future<Thread> getThreadDetailsById({required String threadId});
}
