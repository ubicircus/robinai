import 'package:robin_ai/domain/entities/chat_message_class.dart';

class Thread {
  final String id;
  final List<ChatMessage> messages;
  final String name;

  Thread({
    required this.id,
    required this.messages,
    required this.name,
  });
}
