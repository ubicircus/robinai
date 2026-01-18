import 'package:robin_ai/core/service_names.dart';
import 'package:robin_ai/data/datasources/genui/genui_system_prompt.dart';
import 'package:robin_ai/data/datasources/genui/genui_system_prompt_builder.dart';
import 'package:robin_ai/data/datasources/llm_models/ModelFactoryInterface.dart';
import 'package:robin_ai/data/model/chat_message_network_model.dart';
import 'package:robin_ai/data/datasources/llm_models/ModelInterface.dart';
import 'package:robin_ai/domain/entities/chat_message_class.dart';
import 'package:robin_ai/domain/entities/mcp_tool.dart';
import 'package:robin_ai/presentation/config/context/model/context_model.dart';
import 'package:robin_ai/presentation/config/services/mcp_server_service.dart';

class ChatNetworkDataSource {
  final ModelFactoryInterface _modelFactory;
  final McpServerService? _mcpServerService;

  ChatNetworkDataSource({
    required ModelFactoryInterface modelFactory,
    McpServerService? mcpServerService,
  })  : _modelFactory = modelFactory,
        _mcpServerService = mcpServerService;

  // POST request to send a message
  Future<String> sendChatMessage(
    ChatMessageNetworkModel message,
    ServiceName serviceName,
    String modelName,
    List<ChatMessage> conversationHistory,
    ContextModel context,
  ) async {
    // Get the modelInterface for the specific service
    final ModelInterface modelInterface = _modelFactory.getService(serviceName);

    // Now you can use this instance for making network requests
    print(context.name);
    
    // Get MCP tools if service is available
    List<dynamic>? mcpToolsJson;
    if (_mcpServerService != null) {
      try {
        final tools = await _mcpServerService.getAvailableTools();
        mcpToolsJson = tools.map((t) => t.toJson()).toList();
      } catch (e) {
        print('Failed to get MCP tools: $e');
      }
    }
    
    // Build system prompt with GenUI and MCP tools
    final basePrompt = context.text + '\n\n' + genUiSystemPrompt;
    final systemPrompt = GenUiSystemPromptBuilder.buildSystemPrompt(
      basePrompt: basePrompt,
      mcpTools: mcpToolsJson != null
          ? mcpToolsJson.map((t) => McpTool.fromJson(t)).toList()
          : null,
    );
    
    return modelInterface.sendChatMessageModel(
      modelName: modelName,
      message: message.content,
      conversationHistory: conversationHistory,
      systemPrompt: systemPrompt,
//       systemPrompt: '''
// You are an AI assistant designed for concise, engaging conversations. Follow these rules:
// - Use the fewest words possible while maintaining clarity, impact and natural language
// - Keep a friendly, casual tone with occasional colloquialisms
// - Ask for clarification to avoid assumptions
// - Focus solely on instructions and provide relevant, comprehensive responses
// - Continuously improve based on user feedback
// Let's keep it concise and engaging!
// ''',
    ); // this will be implemented later
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
