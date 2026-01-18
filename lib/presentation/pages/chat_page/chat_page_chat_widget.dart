import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

import 'package:robin_ai/domain/entities/chat_message_class.dart';
import 'package:robin_ai/presentation/bloc/chat_bloc.dart';
import 'package:robin_ai/presentation/services/calendar_event_service.dart';
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
  final ScrollController _scrollController = ScrollController();

  // Claude-inspired theme colors
  static const Color bgLight = Color(0xFFFAF9F6); // Warm off-white
  static const Color surfaceColor = Colors.white;
  static const Color userBubbleColor = Color(0xFFE5E5E0); // Muted warm gray
  static const Color accentColor = Color(0xFFDA7756); // Burnt orange/terracotta accent

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Set the chat context for CalendarEventService
    WidgetsBinding.instance.addPostFrameCallback((_) {
      CalendarEventService.instance.setChatContext(context);
    });

    return BlocBuilder<ChatBloc, ChatState>(builder: (context, state) {
      if (state.thread == null) {
        return Container(
          color: bgLight,
          child: const Center(child: Text("Select a conversation")),
        );
      }

      // Messages are stored newest first (index 0 is newest), so reverse for display
      final messages = state.thread!.messages.reversed.toList();

      return Container(
        color: bgLight,
        child: Column(
          children: [
            Expanded(
              child: messages.isEmpty
                  ? _buildEmptyState()
                  : ListView.separated(
                      controller: _scrollController,
                      padding: const EdgeInsets.all(20),
                      itemCount: messages.length + 1, // +1 for spacing at bottom
                      separatorBuilder: (c, i) => const SizedBox(height: 24),
                      itemBuilder: (context, index) {
                        if (index == messages.length) {
                          return const SizedBox(height: 80); // Bottom padding
                        }
                        final message = messages[index];
                        return _buildMessageItem(message);
                      },
                    ),
            ),
            _buildInputArea(state.thread!.id),
          ],
        ),
      );
    });
  }

  Widget _buildMessageItem(ChatMessage message) {
    final isUser = message.isUserMessage;
    final hasGenUi =
        message.uiComponents != null && message.uiComponents!.isNotEmpty;

    if (isUser) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 300),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: userBubbleColor,
                borderRadius: BorderRadius.circular(16),
              ),
              child: message.content.isNotEmpty
                  ? MarkdownBody(
                      data: message.content,
                      selectable: true,
                      styleSheet: MarkdownStyleSheet(
                        p: const TextStyle(
                          fontSize: 16,
                          color: Colors.black87,
                          height: 1.4,
                        ),
                        strong: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                        code: const TextStyle(
                          color: Colors.black87,
                          backgroundColor: Colors.transparent,
                          fontFamily: 'Courier',
                        ),
                        codeblockDecoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        blockquoteDecoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        listBullet: const TextStyle(
                          color: Colors.black87,
                        ),
                      ),
                    )
                  : const SizedBox.shrink(),
            ),
          ),
          const SizedBox(width: 12),
          const CircleAvatar(
            backgroundColor: Colors.teal,
            radius: 16,
            child: Icon(Icons.person, size: 20, color: Colors.white),
          ),
        ],
      );
    } else {
      // AI message
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Text content
          if (message.content.isNotEmpty)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: accentColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.smart_toy_outlined,
                      size: 20, color: Colors.white),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: MarkdownBody(
                    data: message.content,
                    selectable: true,
                    styleSheet: MarkdownStyleSheet(
                      p: const TextStyle(
                        fontSize: 16,
                        color: Colors.black87,
                        height: 1.5,
                      ),
                      strong: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                      code: const TextStyle(
                        color: Colors.black87,
                        backgroundColor: Colors.transparent,
                        fontFamily: 'Courier',
                      ),
                      codeblockDecoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      blockquoteDecoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      listBullet: const TextStyle(
                        color: Colors.black87,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          // GenUI Component
          if (hasGenUi)
            Padding(
              padding: const EdgeInsets.only(left: 44, top: 12),
              child: GenUiHistoryWidget(
                  uiComponents: message.uiComponents!),
            ),
        ],
      );
    }
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: surfaceColor,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: const Icon(Icons.auto_awesome, size: 48, color: accentColor),
          ),
          const SizedBox(height: 24),
          const Text(
            "How can I help you today?",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputArea(String threadId) {
    return Container(
      color: Colors.transparent,
      padding: const EdgeInsets.only(left: 16, right: 16, bottom: 32, top: 10),
      child: SafeArea(
        child: Container(
          decoration: BoxDecoration(
            color: surfaceColor,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 20,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.add, color: Colors.black45),
                onPressed: _handleAttachmentPressed,
              ),
              Expanded(
                child: TextField(
                  controller: _textController,
                  decoration: const InputDecoration(
                    hintText: "Message...",
                    border: InputBorder.none,
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 8, vertical: 16),
                  ),
                  minLines: 1,
                  maxLines: 5,
                  onSubmitted: (_) {
                    if (_textController.text.trim().isNotEmpty) {
                      _handleSendMessage(context, _textController.text, threadId);
                      _textController.clear();
                    }
                  },
                ),
              ),
              IconButton(
                icon: const Icon(Icons.mic_none, color: Colors.black45),
                onPressed: () {},
              ),
              Container(
                margin: const EdgeInsets.only(right: 8),
                decoration: const BoxDecoration(
                  color: accentColor,
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: const Icon(Icons.arrow_upward,
                      color: Colors.white, size: 20),
                  onPressed: () {
                    if (_textController.text.trim().isNotEmpty) {
                      _handleSendMessage(
                          context, _textController.text, threadId);
                      _textController.clear();
                      // Scroll to bottom after sending
                      Future.delayed(const Duration(milliseconds: 100), () {
                        if (_scrollController.hasClients) {
                          _scrollController.animateTo(
                            _scrollController.position.maxScrollExtent,
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeOut,
                          );
                        }
                      });
                    }
                  },
                ),
              ),
            ],
          ),
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
