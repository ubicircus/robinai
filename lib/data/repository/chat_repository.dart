import 'dart:async';

import '../../domain/entities/chat_message_class.dart';
import '../datasources/chat_local.dart';
import '../datasources/chat_network.dart';

class ChatRepository {
  final ChatNetworkDataSource networkDataSource;
  final ChatLocalDataSource localDataSource;

  ChatRepository(
      {required this.networkDataSource, required this.localDataSource});

  Future<ChatMessageClass> sendChatMessage(ChatMessageClass message) async {
    try {
      // Save user's message to local storage
      await localDataSource.addChatMessage(message);

      // Send the message to OpenAI API
      final responseMessage = await networkDataSource.sendChatMessage(message);

      // Save OpenAI's response to local storage
      await localDataSource.addChatMessage(responseMessage);

      // Return OpenAI's response message
      return responseMessage;
    } catch (error) {
      // Handle or rethrow the error happens while sending message or saving in local DB
      throw error;
    }
  }

  Future<List<ChatMessageClass>> fetchChatMessages() async {
    try {
      // Fetch messages only from local storage
      final localMessages = await localDataSource.getChatMessages();

      if (localMessages.isEmpty) {
        throw Exception('No local messages found.');
      }

      return localMessages;
    } catch (error) {
      // Handle or rethrow the error happens while fetching chat history from local DB
      throw error;
    }
  }
}
