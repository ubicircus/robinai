import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:robin_ai/data/datasources/chat_local.dart';
import 'package:robin_ai/data/datasources/chat_network.dart';
import 'package:robin_ai/data/repository/chat_repository.dart';
import 'package:robin_ai/domain/entities/chat_message_class.dart';
import 'package:robin_ai/domain/entities/thread_class.dart';
import 'package:robin_ai/domain/usecases/threads/get_last_thread_id_usecase.dart';
import 'package:robin_ai/domain/usecases/threads/get_thread_details_by_id_usecase.dart';
import 'package:robin_ai/presentation/bloc/chat_bloc.dart';

import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:flutter_chat_ui/flutter_chat_ui.dart' hide ChatState;
import 'package:uuid/uuid.dart';
import 'package:robin_ai/domain/usecases/messages/send_message.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.light(),
      home: MultiBlocProvider(
        providers: [
          BlocProvider<ChatBloc>(
            create: (_) => ChatBloc(
              sendMessageUseCase: SendMessageUseCase(
                  chatRepository: ChatRepository(
                      networkDataSource: ChatNetworkDataSource(),
                      chatLocalDataSource: ChatLocalDataSource())),
              chatRepository: ChatRepository(
                  networkDataSource: ChatNetworkDataSource(),
                  chatLocalDataSource: ChatLocalDataSource()),
              getLastThreadIdUseCase: GetLastThreadIdUseCase(
                repository: ChatRepository(
                  networkDataSource: ChatNetworkDataSource(),
                  chatLocalDataSource: ChatLocalDataSource(),
                ),
              ),
              getThreadDetailsByIdUseCase: GetThreadDetailsByIdUseCase(
                chatRepository: ChatRepository(
                  networkDataSource: ChatNetworkDataSource(),
                  chatLocalDataSource: ChatLocalDataSource(),
                ),
              ),
            ),
          ),
        ],
        child: ChatPage(),
      ),
    );
  }
}

class ChatPage extends StatelessWidget {
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chat Page'),
      ),
      body: BlocBuilder<ChatBloc, ChatState>(
        builder: (context, state) {
          return Chat(
            messages: _mapChatMessages(state.thread!.messages),
            onSendPressed: (message) =>
                _handleSendMessage(context, message, state.thread!.id),
            showUserAvatars: true,
            showUserNames: true,
            user: _user,
            theme: DefaultChatTheme(),
          );
        },
      ),
    );
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
