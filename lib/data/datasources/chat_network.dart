import 'dart:developer';

import 'package:robin_ai/core/service_names.dart';
import 'package:robin_ai/data/datasources/llm_models/ModelFactoryInterface.dart';
import 'package:robin_ai/data/model/chat_message_network_model.dart';
import 'package:robin_ai/data/datasources/llm_models/ModelInterface.dart';
import 'package:robin_ai/domain/entities/chat_message_class.dart';

class ChatNetworkDataSource {
  final ModelFactoryInterface _modelFactory;

  ChatNetworkDataSource({required ModelFactoryInterface modelFactory})
      : _modelFactory = modelFactory;

  // POST request to send a message
  Future<String> sendChatMessage(
      ChatMessageNetworkModel message,
      ServiceName serviceName,
      String modelName,
      List<ChatMessage> conversationHistory) async {
    // Get the modelInterface for the specific service
    final ModelInterface modelInterface = _modelFactory.getService(serviceName);

    // Now you can use this instance for making network requests
    return modelInterface.sendChatMessageModel(
        modelName: modelName,
        message: message.content,
        conversationHistory: conversationHistory,
        systemPrompt:
            'You only talk like Yoda. You cannot use any other speech.'); // this will be implemented later
  }

  Future<List<String>> getModels({required ServiceName serviceName}) async {
    final ModelInterface modelInterface = _modelFactory.getModels(serviceName);

    return modelInterface.getModels(serviceName: serviceName);
  }
}

//there should be more options, messages list, service provider, model, etc. and there should be default values from the shared preferences


//OLD WAY:
// Future<dynamic> askLLM(String input) async {
//   AppSettingsService appSettingsService = AppSettingsService();
//   appSettingsService.readApiKeys();
//   final ChatOpenAI model = ChatOpenAI(
//     apiKey: appSettingsService.getOpenAIKey(),
//     model: 'gpt-3.5-turbo-0613',
//   );

//   final SystemChatMessagePromptTemplate promptTemplate =
//       SystemChatMessagePromptTemplate.fromTemplate('You only talk like yoda\n');

//   final HumanChatMessagePromptTemplate humanTemplate =
//       HumanChatMessagePromptTemplate.fromTemplate('{text}');

//   final ChatPromptTemplate chatPrompt = ChatPromptTemplate.fromPromptMessages([
//     promptTemplate,
//     humanTemplate,
//   ]);

//   const StringOutputParser stringOutputParser = StringOutputParser();
//   final Runnable chain =
//       Runnable.fromList([chatPrompt, model, stringOutputParser]);

//   var result = await chain.invoke({'text': input});

//   return result;
// }
