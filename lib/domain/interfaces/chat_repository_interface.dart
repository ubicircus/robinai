import 'dart:async';

import 'package:robin_ai/domain/entities/thread_class.dart';

import '../../domain/entities/chat_message_class.dart';

abstract class IChatRepository {
  Future<ChatMessage> sendChatMessage(
      {required String threadId, required ChatMessage message});

  Future<List<Thread>> fetchAllThreads();

  Future<Thread> getThreadDetailsById({required String threadId});
}
