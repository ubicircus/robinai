import 'package:langchain/langchain.dart' hide ChatMessage;
import 'package:langchain_openai/langchain_openai.dart';
import 'package:robin_ai/services/app_settings_service.dart';

import '../../env/env.dart';
import '../model/chat_message_network_model.dart';
import '../model/chat_message_network_mapper.dart'; // Make sure to import the mapper

class ChatNetworkDataSource {
  // POST request to send a message
  Future<ChatMessageNetworkModel> sendChatMessage(
      ChatMessageNetworkModel message) async {
    print(message.content);
    final dynamic response = await askLLM(message.content);

    // Use a mapper to convert network model back to domain entity
    return ChatMessageMapper.fromNetworkResponse(response);
  }
}

Future<dynamic> askLLM(String input) async {
  AppSettingsService appSettingsService = AppSettingsService();
  appSettingsService.readApiKeys();
  final ChatOpenAI model = ChatOpenAI(
    apiKey: appSettingsService.getOpenAIKey(),
    model: 'gpt-3.5-turbo-0613',
  );

  final SystemChatMessagePromptTemplate promptTemplate =
      SystemChatMessagePromptTemplate.fromTemplate('You only talk like yoda\n');

  final HumanChatMessagePromptTemplate humanTemplate =
      HumanChatMessagePromptTemplate.fromTemplate('{text}');

  final ChatPromptTemplate chatPrompt = ChatPromptTemplate.fromPromptMessages([
    promptTemplate,
    humanTemplate,
  ]);

  const StringOutputParser stringOutputParser = StringOutputParser();
  final Runnable chain =
      Runnable.fromList([chatPrompt, model, stringOutputParser]);

  var result = await chain.invoke({'text': input});

  return result;
}
