import 'package:robin_ai/data/model/thread_model.dart';
import 'package:robin_ai/domain/entities/thread_class.dart';
import 'message_mapper.dart';

class ThreadMapper {
  static Thread toDomain(ThreadModel threadModel) {
    return Thread(
      id: threadModel.id,
      name: threadModel.name,
      messages: threadModel.messages
          .map((message) => MessageMapper.toDomain(message))
          .toList(),
    );
  }

  static ThreadModel fromDomain(Thread thread) {
    return ThreadModel(
      id: thread.id,
      name: thread.name,
      messages: thread.messages
          .map((message) => MessageMapper.fromDomain(message))
          .toList(),
    );
  }
}
