import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

import 'package:robin_ai/core/constants.dart';
import 'package:robin_ai/domain/entities/chat_message_class.dart';
import 'package:robin_ai/presentation/bloc/chat_bloc.dart';
import 'package:uuid/uuid.dart';
import 'package:image_picker/image_picker.dart';
import '../../genui/widgets/gen_ui_history_widget.dart';

class ChatPageChatWidget extends StatefulWidget {
  const ChatPageChatWidget({super.key});

  @override
  State<ChatPageChatWidget> createState() => _ChatPageChatWidgetState();
}

class _ChatPageChatWidgetState extends State<ChatPageChatWidget> {
  final TextEditingController _textController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ChatBloc, ChatState>(builder: (context, state) {
      if (state.thread == null) {
        return const Center(child: Text("Select a conversation"));
      }

      final messages = state.thread!.messages.toList();

      return Column(
        children: [
          Expanded(
            child: ListView.builder(
              reverse: true,
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final message = messages[index];
                return _buildMessageItem(message);
              },
            ),
          ),
          _buildInputArea(state.thread!.id),
        ],
      );
    });
  }

  Widget _buildMessageItem(ChatMessage message) {
    final isUser = message.isUserMessage;
    // Check key "ui_components" or "uiComponents" depending on how map was saved,
    // but ChatMessage entity has field `uiComponents`.
    final hasGenUi =
        message.uiComponents != null && message.uiComponents!.isNotEmpty;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Column(
        crossAxisAlignment:
            isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          // Text Bubble
          if (message.content.isNotEmpty)
            Container(
              constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width * 0.75),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: isUser ? Colors.teal : AppColors.lightSage,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(20),
                  topRight: const Radius.circular(20),
                  bottomLeft: isUser
                      ? const Radius.circular(20)
                      : const Radius.circular(0),
                  bottomRight: isUser
                      ? const Radius.circular(0)
                      : const Radius.circular(20),
                ),
              ),
              child: MarkdownBody(
                data: message.content,
                selectable: true,
                styleSheet: MarkdownStyleSheet(
                  p: TextStyle(
                    color: isUser ? Colors.white : Colors.black,
                    fontSize: 16,
                  ),
                  strong: TextStyle(
                      color: isUser ? Colors.white : Colors.black,
                      fontWeight: FontWeight.bold),
                  code: TextStyle(
                    color: isUser ? Colors.white : Colors.black,
                    backgroundColor: Colors.transparent,
                    fontFamily: 'Courier',
                  ),
                  codeblockDecoration: BoxDecoration(
                    color: isUser ? Colors.black26 : Colors.black12,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  blockquoteDecoration: BoxDecoration(
                    color: isUser ? Colors.black26 : Colors.black12,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  listBullet: TextStyle(
                    color: isUser ? Colors.white : Colors.black,
                  ),
                ),
              ),
            ),

          // GenUI Component
          if (hasGenUi)
            Container(
              margin: const EdgeInsets.only(top: 8),
              constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width * 0.9),
              child: GenUiHistoryWidget(uiComponents: message.uiComponents!),
            ),
        ],
      ),
    );
  }

  Widget _buildInputArea(String threadId) {
    return Container(
      padding: const EdgeInsets.all(8.0),
      color: Colors.white,
      child: SafeArea(
        child: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.attachment),
              onPressed: _handleAttachmentPressed,
              color: Colors.teal,
            ),
            Expanded(
              child: TextField(
                controller: _textController,
                decoration: InputDecoration(
                  hintText: 'Type a message',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Colors.grey[100],
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                ),
                minLines: 1,
                maxLines: 5,
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              icon: const Icon(Icons.send),
              onPressed: () {
                if (_textController.text.trim().isNotEmpty) {
                  _handleSendMessage(context, _textController.text, threadId);
                  _textController.clear();
                }
              },
              color: Colors.teal,
            ),
          ],
        ),
      ),
    );
  }

  void _handleSendMessage(BuildContext context, String text, String threadId) {
    print(threadId);
    final chatMessage = ChatMessage(
      id: const Uuid().v4(),
      content: text,
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
      // Logic for image handling can be re-implemented if backend supports it
      // For now we just log it as we moved away from fcu types for main logic
      print("Image selected: ${result.path}");
    }
  }
}
