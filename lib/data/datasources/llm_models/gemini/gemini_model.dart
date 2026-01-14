import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:robin_ai/core/service_names.dart';
import 'package:robin_ai/data/datasources/llm_models/ModelInterface.dart';
import 'package:robin_ai/domain/entities/chat_message_class.dart';
import 'package:robin_ai/presentation/config/services/app_settings_service.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import './gemini_mapper.dart';

class GeminiModelImpl implements ModelInterface {
  Future<GenerativeModel> _createModel(
      String apiKey, String modelName, String systemPrompt) async {
    return GenerativeModel(
      model: modelName,
      apiKey: apiKey,
      systemInstruction:
          systemPrompt.isNotEmpty ? Content.system(systemPrompt) : null,
    );
  }

  @override
  Future<String> sendChatMessageModel({
    required String modelName,
    required String message,
    required List<ChatMessage> conversationHistory,
    required String systemPrompt,
  }) async {
    AppSettingsService appSettingsService = AppSettingsService();
    Map<String, String> apiKeys = await appSettingsService.readApiKeys();
    String? apiKey = apiKeys[ServiceName.gemini.name] ?? '';

    if (apiKey.isEmpty) {
      throw Exception('Gemini API Key not found');
    }

    final model = await _createModel(apiKey, modelName, systemPrompt);

    // Prepare history
    List<Content> history =
        ChatMessageMapper.toGeminiFormat(conversationHistory);

    final chat = model.startChat(history: history);
    final response = await chat.sendMessage(Content.text(message));

    return response.text ?? '';
  }

  @override
  Stream<String> streamChatMessageModel({
    required String modelName,
    required String message,
    required List<ChatMessage> conversationHistory,
    required String systemPrompt,
  }) async* {
    AppSettingsService appSettingsService = AppSettingsService();
    Map<String, String> apiKeys = await appSettingsService.readApiKeys();
    String? apiKey = apiKeys[ServiceName.gemini.name] ?? '';

    if (apiKey.isEmpty) {
      throw Exception('Gemini API Key not found');
    }

    final model = await _createModel(apiKey, modelName, systemPrompt);

    // Prepare history
    List<Content> history =
        ConversationHistoryMapper.toGeminiFormat(conversationHistory);

    final chat = model.startChat(history: history);
    final response = chat.sendMessageStream(Content.text(message));

    await for (final chunk in response) {
      if (chunk.text != null) {
        yield chunk.text!;
      }
    }
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
    AppSettingsService appSettingsService = AppSettingsService();
    Map<String, String> apiKeys = await appSettingsService.readApiKeys();
    final apiKey = apiKeys[serviceName.name] ?? '';

    if (apiKey.isEmpty) {
      return ['gemini-1.5-flash', 'gemini-1.5-pro', 'gemini-1.0-pro'];
    }

    try {
      final url = Uri.parse(
          'https://generativelanguage.googleapis.com/v1/models?key=$apiKey');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List models = data['models'] ?? [];
        return models
            .where((m) => (m['supportedGenerationMethods'] as List)
                .contains('generateContent'))
            .map((m) => m['name'] as String)
            .map((name) => name.replaceFirst('models/', ''))
            .toList();
      }
    } catch (e) {
      print('Error fetching Gemini models: $e');
    }

    return ['gemini-1.5-flash', 'gemini-1.5-pro', 'gemini-1.0-pro'];
  }
}

class ConversationHistoryMapper {
  static List<Content> toGeminiFormat(List<ChatMessage> conversationHistory) {
    return ChatMessageMapper.toGeminiFormat(conversationHistory);
  }
}
