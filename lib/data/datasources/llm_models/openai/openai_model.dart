import 'package:dart_openai/dart_openai.dart';
import 'package:robin_ai/core/service_names.dart';
import 'package:robin_ai/data/datasources/llm_models/ModelInterface.dart';
import 'package:robin_ai/data/datasources/llm_models/openai/openai_mapper.dart';
import 'package:robin_ai/domain/entities/chat_message_class.dart';
import 'package:robin_ai/presentation/config/services/app_settings_service.dart';

class OpenAIModel implements ModelInterface {
  @override
  Future<String> sendChatMessageModel({
    required String modelName,
    required String message,
    required List<ChatMessage> conversationHistory,
    required String systemPrompt,
  }) async {
    AppSettingsService appSettingsService = AppSettingsService();
    Map<String, String> apiKeys = await appSettingsService.readApiKeys();

    OpenAI.apiKey = apiKeys[ServiceName.openai.name] ?? '';
    final openai = OpenAI.instance;

    // Map conversation history to the required format
    List<OpenAIChatCompletionChoiceMessageModel> conversationHistoryMapped =
        ChatMessageMapper.toModelFormat(conversationHistory);

// Define the system message
    final systemMessage = OpenAIChatCompletionChoiceMessageModel(
      content: [
        OpenAIChatCompletionChoiceMessageContentItemModel.text(systemPrompt),
      ],
      role: OpenAIChatMessageRole.system,
    );
// Define the user message
    final userMessage = OpenAIChatCompletionChoiceMessageModel(
      content: [
        OpenAIChatCompletionChoiceMessageContentItemModel.text(message),
      ],
      role: OpenAIChatMessageRole.user,
    );

    // Create a list of messages
    final requestMessages = [
      ...conversationHistoryMapped,
      systemMessage,
      userMessage
    ];
    // Send the chat completion request
    final chatCompletion = await openai.chat.create(
      model: modelName,
      messages: requestMessages,
      temperature: 0.9,
      maxTokens: 500,
    );

    // Retrieve the completed message from the choices
    final completedMessage = chatCompletion.choices.first.message.content
        ?.map((item) => item.text)
        .join('');

    return completedMessage ?? '';
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
    OpenAI.apiKey = apiKeys[ServiceName.openai.name] ?? '';
    final openai = OpenAI.instance;

    List<OpenAIChatCompletionChoiceMessageModel> conversationHistoryMapped =
        ChatMessageMapper.toModelFormat(conversationHistory);

    final systemMessage = OpenAIChatCompletionChoiceMessageModel(
      content: [
        OpenAIChatCompletionChoiceMessageContentItemModel.text(systemPrompt),
      ],
      role: OpenAIChatMessageRole.system,
    );

    final userMessage = OpenAIChatCompletionChoiceMessageModel(
      content: [
        OpenAIChatCompletionChoiceMessageContentItemModel.text(message),
      ],
      role: OpenAIChatMessageRole.user,
    );

    final requestMessages = [
      ...conversationHistoryMapped,
      systemMessage,
      userMessage
    ];

    final chatStream = openai.chat.createStream(
      model: modelName,
      messages: requestMessages,
      temperature: 0.9,
      maxTokens: 500,
    );

    await for (final response in chatStream) {
      final text = response.choices.first.delta.content
          ?.map((item) => item?.text)
          .join('');
      if (text != null) {
        yield text;
      }
    }
  }

  @override
  Future<String> sendAudioFile(String modelName, List<int> audioData) {
    // Handle the case where sending audio files is not supported by the model
    // You can return null or throw an exception depending on your needs

    throw UnimplementedError(
        'Sending audio files is not supported for this model');
  }

  @override
  Future<List<String>> getModels({required ServiceName serviceName}) async {
    AppSettingsService appSettingsService = AppSettingsService();
    Map<String, String> apiKeys = await appSettingsService.readApiKeys();
    OpenAI.apiKey = apiKeys[ServiceName.openai.name] ?? '';
    final openai = OpenAI.instance;
    try {
      List<OpenAIModelModel> models = await openai.model.list();
      List<OpenAIModelModel> gptModels = models
          .where((element) => element.id.contains('gpt'))
          .toList(); // super dirty, but chooses models that are text ones, cannot check it other way for this moment
      return ChatMessageMapper.toListModel(gptModels);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<List<int>> getImage(String modelName, String dalleCode) {
    // Handle the case where sending audio files is not supported by the model
    // You can return null or throw an exception depending on your needs

    throw UnimplementedError(
        'Sending audio files is not supported for this model');
  }
}
