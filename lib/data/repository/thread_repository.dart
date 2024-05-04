import 'package:robin_ai/data/datasources/chat_local.dart';
import 'package:robin_ai/data/model/thread_model.dart';
import 'package:robin_ai/domain/entities/thread_class.dart';
import 'package:robin_ai/domain/interfaces/thread_repository_interface.dart';
import 'package:robin_ai/domain/mappers/thread_mapper.dart';
import '../../domain/entities/exceptions.dart';
import '../../../core/error_messages.dart';

class ThreadRepository implements IThreadRepository {
  final ChatLocalDataSource chatLocalDataSource;

  ThreadRepository({
    required this.chatLocalDataSource,
  });

  Future<void> ensureInitialized() async {
    if (!chatLocalDataSource.isInitialized) {
      await chatLocalDataSource.initialize();
    }
  }

  @override
  Future<List<Thread>> fetchAllThreads() async {
    await ensureInitialized();

    try {
      List<ThreadModel> threadModels = chatLocalDataSource.getAllThreads();
      List<Thread> threads =
          threadModels.map((model) => ThreadMapper.toDomain(model)).toList();
      return threads;
    } catch (error) {
      print('Failed to fetch all threads: $error');
      throw ErrorMessages.fetchThreadsFailed;
    }
  }

  @override
  Future<Thread> getThreadDetailsById({required String threadId}) async {
    await ensureInitialized();

    try {
      ThreadModel? threadModel = chatLocalDataSource.getThreadById(threadId);
      if (threadModel == null) {
        throw ThreadDetailsNotFoundException();
      }
      Thread thread = ThreadMapper.toDomain(threadModel);
      return thread;
    } catch (error) {
      print('Failed to fetch thread details by ID: $error');
      throw ErrorMessages.fetchThreadDetailsFailed;
    }
  }
}
