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
      // await localDataSource.addChatMessage(message);

      // Send the message to OpenAI API
      final responseMessage = await networkDataSource.sendChatMessage(message);

      // Save OpenAI's response to local storage
      // await localDataSource.addChatMessage(responseMessage);

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

      // Check if localMessages is not empty and return the messages.
      // Otherwise, return an empty list instead of throwing an exception.
      return localMessages.isNotEmpty ? localMessages : [];
    } catch (error) {
      // You might want to log this error or handle it differently
      print('An error occurred while fetching chat messages: $error');
      // You could return an empty list here as well, depending on your needs.
      // But for now, let's rethrow the error so we can handle it upstream.
      throw error;
    }
  }
}
