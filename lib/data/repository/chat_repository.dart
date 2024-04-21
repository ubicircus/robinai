import 'dart:async';

import '../../domain/entities/chat_message_class.dart';
import '../../domain/interfaces/chat_repository_interface.dart';
import '../datasources/chat_network.dart';
import '../../../core/error_messages.dart';
import '../model/chat_message_network_model.dart';
import '../model/chat_message_mapper.dart'; // Import the mapper

class ChatRepository implements IChatRepository {
  final ChatNetworkDataSource networkDataSource;

  ChatRepository({required this.networkDataSource});

  Future<ChatMessage> sendChatMessage(ChatMessage message) async {
    try {
      ChatMessageNetworkModel networkModel =
          ChatMessageMapper.toNetworkModel(message);

      // Process the message
      ChatMessageNetworkModel responseNetworkModel =
          await _sendMessageToNetworkAndGetResponse(networkModel);
      ChatMessage responseMessage =
          ChatMessageMapper.fromNetworkModel(responseNetworkModel);

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
