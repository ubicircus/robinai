import 'dart:async';

import 'package:robin_ai/core/service_names.dart';
import 'package:robin_ai/presentation/config/context/model/context_model.dart';

import '../../domain/entities/chat_message_class.dart';

abstract class IChatMessageRepository {
  Future<ChatMessage> sendChatMessage({
    required String threadId,
    required ChatMessage message,
    required ServiceName serviceName,
    required String modelName,
    required List<ChatMessage> chatHistory,
    required ContextModel context,
  });
}
