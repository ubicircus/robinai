import 'package:robin_ai/core/service_names.dart';
import 'package:robin_ai/domain/entities/chat_message_class.dart';

abstract class ModelInterface {
  Future<String> sendChatMessageModel({
    required String modelName,
    required String message,
    required List<ChatMessage> conversationHistory,
    required String systemPrompt,
  });

  Stream<String> streamChatMessageModel({
    required String modelName,
    required String message,
    required List<ChatMessage> conversationHistory,
    required String systemPrompt,
  });

  Future<String> sendAudioFile(
    String modelName,
    List<int> audioData,
  );

  Future<List<String>> getModels({
    required ServiceName serviceName,
  });

  Future<List<int>> getImage(
    String modelName,
    String dalleCode,
  );
}
