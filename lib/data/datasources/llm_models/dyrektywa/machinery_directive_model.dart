import 'dart:convert';
import 'package:robin_ai/core/service_names.dart';
import 'package:robin_ai/data/datasources/llm_models/ModelInterface.dart';
import 'package:robin_ai/data/datasources/llm_models/dyrektywa/machinery_directive_mapper.dart';

import 'package:robin_ai/domain/entities/chat_message_class.dart';
import 'package:http/http.dart' as http;
import 'package:robin_ai/services/app_settings_service.dart';

class DyrektywaModel implements ModelInterface {
  @override
  Future<String> sendChatMessageModel({
    required String modelName,
    required String message,
    required List<ChatMessage> conversationHistory,
    required String systemPrompt,
  }) async {
    AppSettingsService appSettingsService = AppSettingsService();
    Map<String, String> apiKeys = await appSettingsService.readApiKeys();
    String? apiKey = apiKeys[ServiceName.dyrektywa.name] ?? '';

    Uri apiUrl = Uri.parse('https://standardy.kn34.ddns.me/talk');
    ; // Ensure Constants.talkUrl is available in your codebase

    final jsonPayload = jsonEncode({
      'question': message,
      'history': ChatMessageMapper.toJson(conversationHistory),
    });

    try {
      var response = await http.post(
        apiUrl,
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Accept': '*/*',
          'X-API-KEY': apiKey,
        },
        body: jsonPayload,
      );

      if (response.statusCode == 200) {
        final responseBody = json.decode(response.body);
        return responseBody['reply'];
      } else {
        throw Exception(
            'Failed to send message. Status code: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to send message: $e');
    }
  }

  @override
  Future<String> sendAudioFile(String modelName, List<int> audioData) {
    // implement according to your backend logic for audio files
    throw UnimplementedError();
  }

  @override
  Future<List<String>> getModels({required ServiceName serviceName}) async {
    return Future.value([
      'DyrektywaMaszynowa',
    ]);
  }

  @override
  Future<List<int>> getImage(String modelName, String dalleCode) {
    // implement according to your backend logic for getting images
    throw UnimplementedError();
  }
}
