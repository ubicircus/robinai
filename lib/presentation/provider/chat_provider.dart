import 'package:flutter/foundation.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:robin_ai/domain/mappers/chat_message_mapper.dart';
import 'package:robin_ai/domain/usecases/messages/send_message.dart';
import '../../domain/entities/chat_message_class.dart';

import 'package:uuid/uuid.dart';

class ChatProvider with ChangeNotifier {
  final SendMessageUseCase sendMessageUseCase;
  List<types.Message> messages = [];

  ChatProvider({required this.sendMessageUseCase});

  void addMessage(types.Message message) {
    messages.insert(0, message);
    notifyListeners();
  }

  Future<void> handleSendPressed(String text) async {
    final textMessage = types.TextMessage(
      author: types.User(
          id: const Uuid()
              .v4()), // Assume every sent message is from a new user for now
      createdAt: DateTime.now().millisecondsSinceEpoch,
      id: const Uuid().v4(),
      text: text,
    );

    // Convert UI model to domain model for repository handling
    final chatMessage = MessageMapper.textMessageToChatMessage(textMessage);

    try {
      final sendMessage = await sendMessageUseCase.call(chatMessage);
      // Optionally convert back to UI model if the response is required to update the UI
      final uiMessage = MessageMapper.chatMessageToTextMessage(sendMessage);
      addMessage(uiMessage);
    } catch (e) {
      print('Error when sending message: $e');
      // Handle error state if needed
    }
  }
}
