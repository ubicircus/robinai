import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:robin_ai/core/service_names.dart';
import 'package:robin_ai/data/datasources/llm_models/ModelInterface.dart';
import 'package:robin_ai/data/model/perplexity_message_model.dart';
import 'package:robin_ai/domain/entities/chat_message_class.dart';
import 'package:robin_ai/presentation/config/services/app_settings_service.dart';
import 'package:flutter_gemini/flutter_gemini.dart';
import './gemini_mapper.dart';

class GeminiModelImpl implements ModelInterface {
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

    // Initialize Gemini
    Gemini.init(apiKey: apiKey);
    final gemini = Gemini.instance;

    // Map conversation history to the required format
    List<Content> conversationHistoryMapped =
        ChatMessageMapper.toGeminiFormat(conversationHistory);

    // Define the system message

    final systemMessage = Content(
      parts: [Parts(text: systemPrompt)],
      role: 'system',
    );

    // Define the user message
    final userMessage = Content(
      parts: [Parts(text: message)],
      role: 'user',
    );

    // Create a list of messages
    final requestMessages = [
      // systemMessage,
      ...conversationHistoryMapped.reversed,
      // userMessage,
    ];

    // Send the chat completion request
    final chatCompletion = await gemini.chat(
      requestMessages,
      modelName: modelName,
    );

    // Retrieve the completed message from the output
    final completedMessage = chatCompletion?.output;

    return completedMessage ?? '';
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

    // Initialize Gemini
    Gemini.init(apiKey: apiKey);
    final gemini = Gemini.instance;

    try {
      print(
          'Requesting models with apiKey: $apiKey and serviceName: ${serviceName.name}');
      List<GeminiModel> models = await gemini.listModels();
      return models.map((model) => model.name ?? '').toList();
    } catch (e) {
      print('Error in getModels: $e');
      rethrow;
    }
  }
}
