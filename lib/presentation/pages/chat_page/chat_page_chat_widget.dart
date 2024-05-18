import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:flutter_chat_ui/flutter_chat_ui.dart' hide ChatState;
import 'package:robin_ai/core/constants.dart';
import 'package:robin_ai/domain/entities/chat_message_class.dart';
import 'package:robin_ai/presentation/bloc/chat_bloc.dart';
import 'package:uuid/uuid.dart';

class ChatPageChatWidget extends StatefulWidget {
  const ChatPageChatWidget({super.key});

  @override
  State<ChatPageChatWidget> createState() => _ChatPageChatWidgetState();
}

class _ChatPageChatWidgetState extends State<ChatPageChatWidget> {
  final _user = const types.User(
      id: '82091008-a484-4a89-ae75-a22bf8d6f3ac',
      firstName: 'user',
      lastName: 'user');

  final _bot = const types.User(
      id: '82091008-a484-4a89-ae75-a22bf8d6f3bh',
      firstName: 'bot',
      lastName: 'bot');

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ChatBloc, ChatState>(builder: (context, state) {
      return Chat(
        messages: _mapChatMessages(state.thread!.messages),
        onSendPressed: (message) =>
            _handleSendMessage(context, message, state.thread!.id),
        showUserAvatars: true,
        showUserNames: true,
        user: _user,
        theme: DefaultChatTheme(
          primaryColor: Colors.teal,
          backgroundColor: AppColors.lightSage,
          inputBackgroundColor: Colors.white,
          inputContainerDecoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(8.0),
              topRight: Radius.circular(8.0),
            ),
            border: Border(
              top: BorderSide(
                color: Colors.teal.shade100,
                width: 1.0,
              ),
            ),
          ),
          inputTextColor: Colors.black,
          dateDividerTextStyle: TextStyle(
            color: Colors.teal.shade600,
          ),
          receivedMessageBodyTextStyle: TextStyle(
            color: Colors.black,
          ),
          sentMessageBodyTextStyle: TextStyle(
            color: Colors.white,
          ),
        ),
      );
    });
  }

  List<types.Message> _mapChatMessages(List<ChatMessage> messages) {
    return messages.map((chatMessage) {
      if (chatMessage.isUserMessage) {
        return types.TextMessage(
          author: _user,
          createdAt: chatMessage.timestamp.millisecondsSinceEpoch,
          id: chatMessage.id,
          text: chatMessage.content,
        );
      } else {
        return types.TextMessage(
          author: _bot,
          createdAt: chatMessage.timestamp.millisecondsSinceEpoch,
          id: chatMessage.id,
          text: chatMessage.content,
        );
      }
    }).toList();
  }

  void _handleSendMessage(
      BuildContext context, types.PartialText message, String threadId) {
    print(threadId);
    final chatMessage = ChatMessage(
      id: const Uuid().v4(),
      content: message.text,
      isUserMessage: true,
      timestamp: DateTime.now(),
    );

    context
        .read<ChatBloc>()
        .add(SendMessageEvent(threadId: threadId, chatMessage: chatMessage));
  }
}
