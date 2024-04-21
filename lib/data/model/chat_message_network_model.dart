import 'package:uuid/uuid.dart';
import '../../domain/entities/chat_message_class.dart';

class ChatMessageNetworkModel {
  final String id;
  final String content;
  final DateTime timestamp;

  ChatMessageNetworkModel({
    required this.id,
    required this.content,
    required this.timestamp,
  });
}
