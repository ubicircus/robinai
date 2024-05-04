import 'package:robin_ai/core/service_names.dart';
import 'package:uuid/uuid.dart';
import '../../domain/entities/chat_message_class.dart';
import '../../domain/interfaces/chat_message_repository_interface.dart';
import '../datasources/chat_network.dart';
import '../datasources/chat_local.dart';
import '../model/chat_message_network_mapper.dart';
import '../model/chat_message_local_mapper.dart';
import '../model/chat_message_network_model.dart';
import '../../../core/error_messages.dart';

class ChatMessageRepository implements IChatMessageRepository {
  final ChatLocalDataSource chatLocalDataSource;
  final ChatNetworkDataSource chatNetworkDataSource;

  ChatMessageRepository({
    required this.chatNetworkDataSource,
    required this.chatLocalDataSource,
  });

  Future<void> ensureInitialized() async {
    if (!chatLocalDataSource.isInitialized) {
      await chatLocalDataSource.initialize();
    }
  }

  @override
  Future<ChatMessage> sendChatMessage({
    required String threadId,
    required ChatMessage message,
    required ServiceName serviceName,
    required String modelName,
    required List<ChatMessage> chatHistory,
  }) async {
    await ensureInitialized();

    try {
      ChatMessageNetworkModel networkModel =
          ChatMessageMapper.toNetworkModel(message);
      ChatMessageNetworkModel responseNetworkModel =
          await _sendMessageToNetworkAndGetResponse(
        networkModel,
        serviceName,
        modelName,
        chatHistory,
      );
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
  ) async {
    try {
      String response = await chatNetworkDataSource.sendChatMessage(
        message,
        serviceName,
        modelName,
        chatHistory,
      );
      ChatMessageNetworkModel responseModel = ChatMessageNetworkModel(
        id: Uuid().v4(),
        content: response,
        timestamp: DateTime.now(),
      );
      return responseModel;
    } catch (error) {
      print('Failed to send message to network: $error');
      throw ErrorMessages.sendNetworkFailed;
    }
  }
}
