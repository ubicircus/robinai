import 'package:hive/hive.dart';
import 'chat_message_local_model.dart';
import 'package:uuid/uuid.dart';

part 'thread_model.g.dart';

@HiveType(typeId: 1)
class ThreadModel extends HiveObject {
  @HiveField(0)
  final String id; // UUID field

  @HiveField(1)
  final List<ChatMessageLocal> messages;

  @HiveField(2)
  final DateTime lastMessageTime;

  @HiveField(3)
  final String name; // Name of the thread

  ThreadModel(
      {String? id,
      required this.messages,
      required this.lastMessageTime,
      required this.name})
      : this.id = id ?? Uuid().v4();
}
