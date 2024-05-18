import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:flutter_chat_ui/flutter_chat_ui.dart' hide ChatState;
import 'package:robin_ai/core/constants.dart';
import 'package:robin_ai/domain/entities/chat_message_class.dart';
import 'package:robin_ai/presentation/bloc/chat_bloc.dart';
import 'package:uuid/uuid.dart';
import 'package:image_picker/image_picker.dart';

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
        showUserNames: true,
        onAttachmentPressed: _handleAttachmentPressed,
        user: _user,
        theme: DefaultChatTheme(
          primaryColor: Colors.teal,
          backgroundColor: AppColors.lightSage,
          inputBackgroundColor: Colors.white,

          inputContainerDecoration: BoxDecoration(
            color: Colors.white,
            borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20.0),
                topRight: Radius.circular(20.0),
                bottomLeft: Radius.circular(20.0),
                bottomRight: Radius.circular(20.0)),
            border: Border(
              top: BorderSide(
                color: Colors.teal.shade100,
                width: 1.0,
              ),
              bottom: BorderSide(
                color: Colors.teal.shade100,
                width: 1.0,
              ),
            ),
          ),
          inputTextColor: Colors.black,
          dateDividerTextStyle: TextStyle(
            color: Colors.teal.shade600,
          ),
          receivedMessageBodyTextStyle: const TextStyle(
            color: Colors.black,
          ),
          sentMessageBodyTextStyle: const TextStyle(
            color: Colors.white,
          ),
          // inputPadding: const EdgeInsets.only(bottom: 30),
          inputMargin: const EdgeInsets.only(bottom: 10),
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

  void _handleAttachmentPressed() {
    showModalBottomSheet<void>(
      context: context,
      builder: (BuildContext context) => SafeArea(
        child: SizedBox(
          height: 144,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  _handleImageSelection();
                },
                child: const Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: Text('Photo'),
                ),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: Text('Cancel'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _handleImageSelection() async {
    final result = await ImagePicker().pickImage(
      imageQuality: 70,
      maxWidth: 1440,
      source: ImageSource.gallery,
    );

    if (result != null) {
      final bytes = await result.readAsBytes();
      final image = await decodeImageFromList(bytes);

      final message = types.ImageMessage(
        author: _user,
        createdAt: DateTime.now().millisecondsSinceEpoch,
        height: image.height.toDouble(),
        id: const Uuid().v4(),
        name: result.name,
        size: bytes.length,
        uri: result.path,
        width: image.width.toDouble(),
      );

      // _addMessage(message);
    }
  }
}
