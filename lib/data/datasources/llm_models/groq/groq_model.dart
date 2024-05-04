import 'package:dart_openai/dart_openai.dart';
import 'package:robin_ai/core/service_names.dart';
import 'package:robin_ai/data/datasources/ModelInterface.dart';
import 'package:robin_ai/data/datasources/llm_models/openai/openai_mapper.dart';
import 'package:robin_ai/domain/entities/chat_message_class.dart';
import 'package:robin_ai/services/app_settings_service.dart';

class GroqModel implements ModelInterface {
  @override
  Future<String> sendChatMessageModel(
      {required String modelName,
      required String message,
      required List<ChatMessage> conversationHistory,
      required String systemPrompt}) {
    throw UnimplementedError();
  }

  @override
  Future<String> sendAudioFile(String modelName, List<int> audioData) {
    // TODO: implement sendAudioFile
    throw UnimplementedError();
  }

  @override
  Future<List<int>> getImage(String modelName, String dalleCode) {
    // TODO: implement getImage
    throw UnimplementedError();
  }

  @override
  Future<List<String>> getModels({required ServiceName serviceName}) async {
    return Future.value([
      'llama3-8b-8192',
      'llama3-70b-8192',
      'mixtral-8x7b-32768',
      'gemma-7b-it'
    ]);
  }
}
