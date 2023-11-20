import 'package:flutter/material.dart';
import '../../domain/usecases/send_message.dart';
import '../../domain/usecases/fetch_all_messages.dart';
import '../../domain/entities/chat_message_class.dart';

class ChatProvider with ChangeNotifier {
  // Instantiate the usecases
  final SendMessageUseCase sendMessage;
  final FetchAllMessagesUseCase fetchAllMessages;

  // Maintains the messages received
  List<ChatMessageClass> _messages = [];

  // Getter to access the message list
  List<ChatMessageClass> get messages => [..._messages];

  // Constructor taking the usecases as dependencies
  ChatProvider({required this.sendMessage, required this.fetchAllMessages}) {
    // Retrieve the messages when the provider is created
    retrieveMessages();
  }

  // Method to retrieve all the messages
  Future<void> retrieveMessages() async {
    final messages = await fetchAllMessages();
    _messages = messages;
    notifyListeners();
  }

  // Method to add a new message to the list and send it
  Future<void> addMessage(ChatMessageClass message) async {
    _messages.add(message);
    notifyListeners();
    final responseMessage = await sendMessage(message);
    _messages.add(responseMessage);
    notifyListeners();
  }
}
