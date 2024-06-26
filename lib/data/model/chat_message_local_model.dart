import 'package:hive/hive.dart';

part 'chat_message_local_model.g.dart'; // The name of the file that will be generated for type adapters.

//this file is no longer in use - currently all the messages are moved to threads

@HiveType(typeId: 1) // Ensure the typeId is unique within your project
class ChatMessageLocal extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String content;

  @HiveField(2)
  final bool isUserMessage;

  @HiveField(3)
  final DateTime timestamp;

  ChatMessageLocal({
    required this.id,
    required this.content,
    required this.isUserMessage,
    required this.timestamp,
  });

  // Additional methods or logic can go here
}
