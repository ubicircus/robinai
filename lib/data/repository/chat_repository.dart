import 'dart:async';

import 'package:robin_ai/data/datasources/chat_local.dart';
import 'package:robin_ai/data/model/thread_model.dart';
import 'package:robin_ai/domain/entities/exceptions.dart';
import 'package:robin_ai/domain/entities/thread_class.dart';
import 'package:robin_ai/domain/mappers/thread_mapper.dart';

import '../../domain/entities/chat_message_class.dart';
import '../../domain/interfaces/chat_repository_interface.dart';
import '../datasources/chat_network.dart';
import '../../../core/error_messages.dart';
import '../model/chat_message_network_model.dart';
import '../model/chat_message_network_mapper.dart';
import '../model/chat_message_local_mapper.dart';

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
  Future<ChatMessage> sendChatMessage(
      {required String threadId, required ChatMessage message}) async {
    await ensureInitialized();

    try {
      ChatMessageNetworkModel networkModel =
          ChatMessageMapper.toNetworkModel(message);

      // Send the message over the network and handle the response
      ChatMessageNetworkModel responseNetworkModel =
          await _sendMessageToNetworkAndGetResponse(networkModel);
      //add message to local thread storage
      chatLocalDataSource.addMessageToThread(
          threadId, ChatMessageLocalMapper.toLocalModel(message));

      //get response from network
      ChatMessage responseMessage =
          ChatMessageMapper.fromNetworkModel(responseNetworkModel);
      //save response to local thread storage
      chatLocalDataSource.addMessageToThread(
          threadId, ChatMessageLocalMapper.toLocalModel(responseMessage));

      // Optionally log or handle the retrieved messages
      var messages = chatLocalDataSource.getAllMessagesFromThread(threadId);
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

  @override
  Future<List<Thread>> fetchAllThreads() async {
    await ensureInitialized(); // Ensure local data source is initialized

    try {
      // Fetch all threads from the local data source
      List<ThreadModel> threadModels = chatLocalDataSource.getAllThreads();

      // Utilize ThreadMapper to convert ThreadModel to Thread entities
      List<Thread> threads = threadModels
          .map((threadModel) => ThreadMapper.toDomain(threadModel))
          .toList();

      return threads;
    } catch (error) {
      print('Failed to fetch all threads: $error');
      rethrow;
      // throw ErrorMessages.fetchThreadsFailed;
    }
  }

  @override
  Future<Thread> getThreadDetailsById({required String threadId}) async {
    await ensureInitialized(); // Ensure local data source is initialized

    try {
      ThreadModel? threadModel = chatLocalDataSource.getThreadById(threadId);

      if (threadModel == null) {
        throw ThreadDetailsNotFoundException;
      }

      // Utilize ThreadMapper to convert ThreadModel to Thread entity
      Thread thread = ThreadMapper.toDomain(threadModel);

      return thread;
    } catch (error) {
      print('Failed to fetch thread details by ID: $error');
      throw FetchThreadDetailsFailed;
    }
  }
}
