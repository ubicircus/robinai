import 'dart:convert';
import 'package:robin_ai/core/service_names.dart';
import 'package:robin_ai/data/datasources/llm_models/ModelInterface.dart';
import 'package:robin_ai/data/datasources/llm_models/groq/groq_mapper.dart';
import 'package:robin_ai/data/model/groq_message_model.dart';
import 'package:robin_ai/domain/entities/chat_message_class.dart';
import 'package:robin_ai/presentation/config/services/app_settings_service.dart';
import 'package:http/http.dart' as http;

class GroqModel implements ModelInterface {
  @override
  Future<String> sendChatMessageModel({
    required String modelName,
    required String message,
    required List<ChatMessage> conversationHistory,
    required String systemPrompt,
  }) async {
    AppSettingsService appSettingsService = AppSettingsService();
    Map<String, String> apiKeys = await appSettingsService.readApiKeys();
    String? apiKey = apiKeys[ServiceName.groq.name] ?? '';

    // Map conversation history to the required format
    List<GroqChatMessageModel> conversationHistoryMapped =
        ChatMessageMapper.toModelFormat(conversationHistory);

    // Define the system message
    final systemMessage = GroqChatMessageModel(
      role: GroqChatMessageRole.system,
      content: GroqChatMessageContentItemModel.text(systemPrompt),
    );

    // Define the user message
    final userMessage = GroqChatMessageModel(
      role: GroqChatMessageRole.user,
      content: GroqChatMessageContentItemModel.text(message),
    );

    // Create a list of messages
    final requestMessages = [
      ...conversationHistoryMapped.reversed.toList(),
      systemMessage,
      userMessage,
    ];

    // Create a JSON payload for the API request
    final jsonData = {
      'messages': requestMessages
          .map((message) => {
                'role': message.role.value,
                'content': message.content.text,
              })
          .toList(),
      'model': modelName,
      'temperature': 0.5,
      'max_tokens': 1024,
      'top_p': 1.0,
      'stop': null,
      'stream': false,
    };

    // Make a POST request to the Groq API
    final Uri url =
        Uri.parse('https://api.groq.com/openai/v1/chat/completions');
    final headers = {
      'Authorization': 'Bearer $apiKey',
      'Content-Type': 'application/json',
    };
    final response = await http.post(
      url,
      headers: headers,
      body: jsonEncode(jsonData),
    );

    // Check if the response was successful
    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      final completedMessage = responseData['choices'][0]['message']['content'];
      print(completedMessage);

      String correctedString = convertLatin1ToUtf8(completedMessage);

      return correctedString;
    } else {
      throw Exception(
          'Failed to send chat message: ${response.statusCode} - ${response.body}');
    }
  }

  String convertLatin1ToUtf8(String inStr) {
    // Decode from Latin-1
    List<int> latin1Bytes = latin1.encode(inStr);

    // Properly decode to UTF-8
    String utf8String = utf8.decode(latin1Bytes);

    return utf8String;
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
