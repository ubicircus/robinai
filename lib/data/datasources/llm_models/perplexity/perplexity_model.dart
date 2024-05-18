import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:robin_ai/core/service_names.dart';
import 'package:robin_ai/data/datasources/llm_models/ModelInterface.dart';
import 'package:robin_ai/data/datasources/llm_models/perplexity/perplexity_mapper.dart';
import 'package:robin_ai/data/model/perplexity_message_model.dart';
import 'package:robin_ai/domain/entities/chat_message_class.dart';
import 'package:robin_ai/presentation/config/services/app_settings_service.dart';

class PerplexityModel implements ModelInterface {
  @override
  Future<String> sendChatMessageModel({
    required String modelName,
    required String message,
    required List<ChatMessage> conversationHistory,
    required String systemPrompt,
  }) async {
    AppSettingsService appSettingsService = AppSettingsService();
    Map<String, String> apiKeys = await appSettingsService.readApiKeys();
    String? apiKey = apiKeys[ServiceName.perplexity.name] ?? '';

    // Map conversation history to the required format
    List<PerplexityChatMessageModel> conversationHistoryMapped =
        ChatMessageMapper.toModelFormat(conversationHistory);

    // Define the system message
    final systemMessage = PerplexityChatMessageModel(
      role: PerplexityChatMessageRole.system,
      content: PerplexityChatMessageContentItemModel.text(systemPrompt),
    );

    // Define the user message - not used, this message is already in the history
    final userMessage = PerplexityChatMessageModel(
      role: PerplexityChatMessageRole.user,
      content: PerplexityChatMessageContentItemModel.text(message),
    );

    // Create a list of messages
    final requestMessages = [
      systemMessage,
      if (conversationHistoryMapped.isNotEmpty)
        ...conversationHistoryMapped.reversed.toList(),
      // userMessage,
    ];

    print(requestMessages.map((e) => e.role));

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

    // Make a POST request to the Perplexity API
    final Uri url = Uri.parse('https://api.perplexity.ai/chat/completions');
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

      String correctedString = convertLatin1ToUtf8(completedMessage);
      print(completedMessage);
      return completedMessage;
    } else {
      throw Exception(
          'Failed to send chat message: ${response.statusCode} - ${response.body}');
    }
  }

  String convertLatin1ToUtf8(String text) {
    var bytes = latin1.encode(text);
    var utf8Text = utf8.decode(bytes);
    return utf8Text;
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
      'llama-3-sonar-small-32k-chat',
      'llama-3-sonar-small-32k-online',
      'llama-3-sonar-large-32k-chat',
      'llama-3-sonar-large-32k-online',
      'llama-3-8b-instruct',
      'llama-3-70b-instruct',
      'mixtral-8x7b-instruct'
    ]);
  }
}
