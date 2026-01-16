import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

part 'thread_model.g.dart';

@HiveType(typeId: 2)
class ThreadModel extends HiveObject {
  @HiveField(0)
  final String id; // Unique identifier for the thread

  @HiveField(1)
  final List<Message> messages;

  @HiveField(2)
  final String name; // Name of the thread based on topic or participants etc.

  ThreadModel({String? id, List<Message>? messages, required this.name})
      : this.id = id ?? Uuid().v4(),
        this.messages = messages ?? [];
}

// Defines the structure of a singular message within a thread.
@HiveType(typeId: 3) // update Hive typeID to make it unique
class Message extends HiveObject {
  @HiveField(0)
  final String messageID;

  @HiveField(1)
  final String content;

  @HiveField(2)
  final bool isUserMessage;

  @HiveField(3)
  final DateTime timestamp;

  @HiveField(4)
  final Map<String, dynamic>? uiComponents;

  Message({
    required this.messageID,
    required this.content,
    required this.isUserMessage,
    required this.timestamp,
    this.uiComponents,
  });
}
