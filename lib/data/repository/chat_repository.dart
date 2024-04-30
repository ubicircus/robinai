import 'dart:async';

import 'package:robin_ai/data/datasources/chat_local.dart';

import '../../domain/entities/chat_message_class.dart';
import '../../domain/interfaces/chat_repository_interface.dart';
import '../datasources/chat_network.dart';
import '../../../core/error_messages.dart';
import '../model/chat_message_network_model.dart';
import '../model/chat_message_network_mapper.dart';
import '../model/chat_message_local_mapper.dart';
import '../model/chat_message_local_model.dart';

class ChatRepository implements IChatRepository {
  final ChatNetworkDataSource networkDataSource;
  final ChatLocalDataSource chatLocalDataSource;

  ChatRepository({
    required this.networkDataSource,
    required this.chatLocalDataSource,
  });

  Future<void> ensureInitialized() async {
    if (!chatLocalDataSource.isInitialized) {
      await chatLocalDataSource.initialize();
    }
  }

  @override
  Future<ChatMessage> sendChatMessage(ChatMessage message) async {
    await ensureInitialized();

    try {
      ChatMessageNetworkModel networkModel =
          ChatMessageMapper.toNetworkModel(message);

      // Send the message over the network and handle the response
      ChatMessageNetworkModel responseNetworkModel =
          await _sendMessageToNetworkAndGetResponse(networkModel);
      chatLocalDataSource
          .addChatMessageLocal(ChatMessageLocalMapper.toLocalModel(message));

      ChatMessage responseMessage =
          ChatMessageMapper.fromNetworkModel(responseNetworkModel);
      await chatLocalDataSource.addChatMessageLocal(
          ChatMessageLocalMapper.toLocalModel(responseMessage));

      // Optionally log or handle the retrieved messages
      var messages = chatLocalDataSource.getChatMessagesLocal();
      print('Retrieved messages: $messages');

      return responseMessage;
    } catch (error) {
      print('Failed to send message: $error');
      throw ErrorMessages.sendAndSaveFailed;
    }
  }

  Future<ChatMessageNetworkModel> _sendMessageToNetworkAndGetResponse(
      ChatMessageNetworkModel message) async {
    try {
      return await networkDataSource.sendChatMessage(message);
    } catch (error) {
      print('Failed to send message to network: $error');
      throw ErrorMessages.sendNetworkFailed;
    }
  }
}
