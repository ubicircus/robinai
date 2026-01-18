import 'dart:convert';
import 'package:robin_ai/core/service_names.dart';
import 'package:robin_ai/data/datasources/mcp/mcp_tool_executor.dart';
import 'package:robin_ai/data/datasources/mcp/tool_result_formatter.dart';
import 'package:robin_ai/presentation/config/context/model/context_model.dart';
import 'package:robin_ai/presentation/config/services/mcp_server_service.dart';
import 'package:uuid/uuid.dart';
import '../../domain/entities/chat_message_class.dart';
import '../../domain/interfaces/chat_message_repository_interface.dart';
import '../datasources/chat_network.dart';
import '../datasources/chat_local.dart';
import '../datasources/llm_models/ModelFactoryInterface.dart';
import '../model/chat_message_network_mapper.dart';
import '../model/chat_message_local_mapper.dart';
import '../model/chat_message_network_model.dart';
import '../../../core/error_messages.dart';

class ChatMessageRepository implements IChatMessageRepository {
  final ChatLocalDataSource chatLocalDataSource;
  final ChatNetworkDataSource chatNetworkDataSource;
  final McpServerService? mcpServerService;
  final ModelFactoryInterface? modelFactory;

  ChatMessageRepository({
    required this.chatNetworkDataSource,
    required this.chatLocalDataSource,
    this.mcpServerService,
    this.modelFactory,
  });

  Future<void> ensureInitialized() async {
    if (!chatLocalDataSource.isInitialized) {
      await chatLocalDataSource.initialize();
    }
  }

  @override
  Future<ChatMessage> sendChatMessage(
      {required String threadId,
      required ChatMessage message,
      required ServiceName serviceName,
      required String modelName,
      required List<ChatMessage> chatHistory,
      required ContextModel context}) async {
    await ensureInitialized();

    try {
      ChatMessageNetworkModel networkModel =
          ChatMessageMapper.toNetworkModel(message);
      ChatMessageNetworkModel responseNetworkModel =
          await _sendMessageToNetworkAndGetResponse(
              networkModel, serviceName, modelName, chatHistory, context);
      chatLocalDataSource.addMessageToThread(
          threadId, ChatMessageLocalMapper.toLocalModel(message));
      chatLocalDataSource.addMessageToThread(
          threadId,
          ChatMessageLocalMapper.toLocalModel(
              ChatMessageMapper.fromNetworkModel(responseNetworkModel)));
      return ChatMessageMapper.fromNetworkModel(responseNetworkModel);
    } catch (error) {
      print('Failed to send message: $error');
      throw ErrorMessages.sendAndSaveFailed;
    }
  }

  Future<ChatMessageNetworkModel> _sendMessageToNetworkAndGetResponse(
    ChatMessageNetworkModel message,
    ServiceName serviceName,
    String modelName,
    List<ChatMessage> chatHistory,
    ContextModel context,
  ) async {
      try {
        String response = await chatNetworkDataSource.sendChatMessage(
            message, serviceName, modelName, chatHistory, context);
        Map<String, dynamic>? uiComponents;
        String content = response;

        // Check for tool calls in response
        if (mcpServerService != null && modelFactory != null) {
          final toolExecutor = McpToolExecutor(mcpServerService!);
          final toolCall = toolExecutor.parseToolCall(response);
          
          if (toolCall != null) {
            try {
              // Execute tool
              final rawResult = await toolExecutor.executeToolCall(toolCall);
              
              // Format result using LLM agent
              final formatter = ToolResultFormatter(
                modelFactory: modelFactory!,
                serviceName: serviceName,
                modelName: modelName,
              );
              final formattedResult = await formatter.formatResult(rawResult);
              
              // Use formatted result
              content = formattedResult['text'] ?? content;
              if (formattedResult['ui_components'] != null) {
                uiComponents = {'ui_components': formattedResult['ui_components']};
              }
            } catch (e) {
              print('Tool execution or formatting failed: $e');
              // Continue with original response
            }
          }
        }

      try {
        String jsonStr = response;
        // Try extracting from markdown code blocks first
        final codeBlockRegex =
            RegExp(r'```json\s*(\{[\s\S]*?\})\s*```', caseSensitive: false);
        final match = codeBlockRegex.firstMatch(response);

        if (match != null) {
          jsonStr = match.group(1) ?? response;
        } else {
          // Fallback: Try to find the first '{' and last '}'
          final start = response.indexOf('{');
          final end = response.lastIndexOf('}');
          if (start != -1 && end != -1 && end > start) {
            jsonStr = response.substring(start, end + 1);
          }
        }

        final data = json.decode(jsonStr);

        if (data is Map<String, dynamic>) {
          if (data['text'] != null) {
            content = data['text'];
          }
          // If there was text OUTSIDE the JSON code block, we might want to preserve it if data['text'] is empty?
          // But strict contract says data['text'] is the response.
          // However, if the LLM drifted, "content" might be better if combined?
          // For now, let's trust data['text'] if present, but if we parsed a CODE BLOCK,
          // we definitely don't want to show the raw code block in the chat.

          if (data['ui_components'] != null) {
            uiComponents = {'ui_components': data['ui_components']};
          }
        }
      } catch (e) {
        // Not a JSON response, keep original content
        print(
            'Parsing response as JSON failed, treating as plain text: $e. Raw response start: ${response.substring(0, response.length > 50 ? 50 : response.length)}');
      }

      // Strip outer code fences if entire content is wrapped in them
      // This prevents LLM from wrapping markdown examples in code blocks
      final outerCodeFenceRegex =
          RegExp(r'^```(?:[a-z]*\n)?([\s\S]*?)\n?```$', multiLine: true);
      final outerMatch = outerCodeFenceRegex.firstMatch(content.trim());
      if (outerMatch != null) {
        content = outerMatch.group(1) ?? content;
      }

      ChatMessageNetworkModel responseModel = ChatMessageNetworkModel(
        id: Uuid().v4(),
        content: content,
        timestamp: DateTime.now(),
        uiComponents: uiComponents,
      );
      return responseModel;
    } catch (error) {
      print('Failed to send message to network: $error');
      throw ErrorMessages.sendNetworkFailed;
    }
  }
}
