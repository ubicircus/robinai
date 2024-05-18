import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:robin_ai/data/datasources/chat_local.dart';
import 'package:robin_ai/data/datasources/chat_network.dart';
import 'package:robin_ai/data/datasources/llm_models/model_factory.dart';
import 'package:robin_ai/data/repository/chat_message_repository.dart';
import 'package:robin_ai/data/repository/models_repository.dart';
import 'package:robin_ai/data/repository/thread_repository.dart';

import 'package:robin_ai/domain/usecases/get_models_use_case.dart';

import 'package:robin_ai/domain/usecases/threads/get_last_thread_id_usecase.dart';
import 'package:robin_ai/domain/usecases/threads/get_thread_details_by_id_usecase.dart';
import 'package:robin_ai/domain/usecases/threads/get_threads_list_usecase.dart';
import 'package:robin_ai/presentation/bloc/chat_bloc.dart';

import 'package:robin_ai/presentation/pages/chat_page/chat_page.dart';

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
    BlocProvider.of<ChatBloc>(context).add(InitializeAppEvent());
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
                  chatRepository: ChatMessageRepository(
                      chatNetworkDataSource:
                          ChatNetworkDataSource(modelFactory: ModelFactory()),
                      chatLocalDataSource: ChatLocalDataSource())),
              chatRepository: ChatMessageRepository(
                  chatNetworkDataSource:
                      ChatNetworkDataSource(modelFactory: ModelFactory()),
                  chatLocalDataSource: ChatLocalDataSource()),
              getLastThreadIdUseCase: GetLastThreadIdUseCase(
                repository: ThreadRepository(
                  chatLocalDataSource: ChatLocalDataSource(),
                ),
              ),
              getThreadDetailsByIdUseCase: GetThreadDetailsByIdUseCase(
                threadRepository: ThreadRepository(
                  chatLocalDataSource: ChatLocalDataSource(),
                ),
              ),
              getThreadListUseCase: GetThreadListUseCase(
                repository: ThreadRepository(
                  chatLocalDataSource: ChatLocalDataSource(),
                ),
              ),
              getModelsUseCase: GetModelsUseCase(
                  modelsRepository: ModelsRepository(
                chatNetworkDataSource: ChatNetworkDataSource(
                  modelFactory: ModelFactory(),
                ),
              )),
            ),
          ),
        ],
        child: ChatPage(),
      ),
    );
  }
}

// class ChatPage extends StatefulWidget {
//   @override
//   State<ChatPage> createState() => _ChatPageState();
// }

// class _ChatPageState extends State<ChatPage> {
//   final _user = const types.User(
//       id: '82091008-a484-4a89-ae75-a22bf8d6f3ac',
//       firstName: 'user',
//       lastName: 'user');

//   final _bot = const types.User(
//       id: '82091008-a484-4a89-ae75-a22bf8d6f3bh',
//       firstName: 'bot',
//       lastName: 'bot');

//   @override
//   Widget build(BuildContext context) {
//     final ContextModelService _contextModelService = ContextModelService();

//     return Scaffold(
//       appBar: AppBar(
//         toolbarHeight: 100,
//         backgroundColor: AppColors.lightSage,
//         title: FutureBuilder(
//           future: AppSettingsService().readApiKeys(),
//           builder: (context, snapshot) {
//             if (snapshot.hasData) {
//               Map<String, String> apiKeys = snapshot.data!;
//               bool hasApiKey = _hasApiKey(apiKeys);
//               return hasApiKey
//                   ? Column(
//                       crossAxisAlignment: CrossAxisAlignment.end,
//                       children: [
//                         ServicesPopupMenu(),
//                         const SizedBox(height: 15),
//                         ModelsPopupMenu(),
//                       ],
//                     )
//                   : Center(child: ApiKeyNotice());
//             } else {
//               return Center(child: CircularProgressIndicator());
//             }
//           },
//         ),
//         actions: [
//           IconButton(
//             icon: Icon(Icons.restore_page_outlined, size: 36),
//             onPressed: () {
//               context.read<ChatBloc>().add(ClearChatEvent());
//             },
//           )
//         ],
//       ),
//       drawer: Drawer(
//         child: BlocBuilder<ChatBloc, ChatState>(
//           builder: (context, state) {
//             BlocProvider.of<ChatBloc>(context).add(
//                 LoadThreadsEvent()); // Dispatch LoadThreadsEvent to fetch threads
//             return Column(
//               children: [
//                 Expanded(
//                   child: state.threads.isEmpty
//                       ? const Center(
//                           child: Text(
//                               "No threads"), // Show "No threads" text instead of CircularProgressIndicator
//                         )
//                       : ListView.builder(
//                           shrinkWrap: true,
//                           itemCount: state.threads.length,
//                           itemBuilder: (context, index) {
//                             final sortedThreads = state.threads
//                               ..sort((a, b) => b.messages.first.timestamp
//                                   .compareTo(a.messages.first.timestamp));
//                             final thread = sortedThreads[index];
//                             final lastMessage = thread.messages.isNotEmpty
//                                 ? thread.messages.first
//                                 : null;
//                             return GestureDetector(
//                               onTap: () {
//                                 BlocProvider.of<ChatBloc>(context).add(
//                                     LoadMessagesEvent(threadId: thread.id));
//                               },
//                               child: ListTile(
//                                 title: Text(thread.name),
//                                 subtitle: lastMessage != null
//                                     ? Column(
//                                         crossAxisAlignment:
//                                             CrossAxisAlignment.start,
//                                         children: [
//                                           Text(
//                                             lastMessage
//                                                 .content, // Assuming `content` is the attribute for message content
//                                             style: Theme.of(context)
//                                                 .textTheme
//                                                 .bodyText2,
//                                             maxLines: 1,
//                                             overflow: TextOverflow.ellipsis,
//                                           ),
//                                           Text(
//                                             "${DateFormat('HH:mm').format(lastMessage.timestamp)} ${DateFormat('dd MMM yy').format(lastMessage.timestamp)}",
//                                             style: Theme.of(context)
//                                                 .textTheme
//                                                 .caption,
//                                           ),
//                                         ],
//                                       )
//                                     : Text("No Messages"),
//                               ),
//                             );
//                           },
//                         ),
//                 ),
//                 Divider(),
//                 ListTile(
//                   title: Text("Settings"),
//                   leading: Icon(Icons.settings),
//                   onTap: () {
//                     Navigator.pushNamed(
//                         context, '/settings'); // Navigate to the settings page
//                   },
//                 ),
//                 SizedBox(height: 16),
//               ],
//             );
//           },
//         ),
//       ),
//       body: BlocBuilder<ChatBloc, ChatState>(
//         builder: (context, state) {
//           return Chat(
//             messages: _mapChatMessages(state.thread!.messages),
//             onSendPressed: (message) =>
//                 _handleSendMessage(context, message, state.thread!.id),
//             showUserAvatars: true,
//             showUserNames: true,
//             // emptyState: Center(
//             //   child: ContextOptionsWidget(
//             //     futureOptions: _contextModelService.listAllContextModels(),
//             //   ),
//             // ),
//             // onMessageDoubleTap: (context, p1) =>
//             //     Clipboard.setData(ClipboardData(text: p1.)) <-implement laters
//             // listBottomWidget: ContextOptionsWidget(
//             //   futureOptions: _contextModelService.listAllContextModels(),
//             // ),
//             user: _user,
//             theme: DefaultChatTheme(
//               primaryColor: Colors.teal,
//               backgroundColor: AppColors.lightSage,
//               inputBackgroundColor: Colors.white,
//               inputContainerDecoration: BoxDecoration(
//                 color: Colors.white,
//                 borderRadius: BorderRadius.only(
//                   topLeft: Radius.circular(8.0),
//                   topRight: Radius.circular(8.0),
//                 ),
//                 border: Border(
//                   top: BorderSide(
//                     color: Colors.teal.shade100,
//                     width: 1.0,
//                   ),
//                 ),
//               ),
//               inputTextColor: Colors.black,
//               dateDividerTextStyle: TextStyle(
//                 color: Colors.teal.shade600,
//               ),
//               receivedMessageBodyTextStyle: TextStyle(
//                 color: Colors.black,
//               ),
//               sentMessageBodyTextStyle: TextStyle(
//                 color: Colors.white,
//               ),
//             ),
//           );
//         },
//       ),
//     );
//   }

//   List<types.Message> _mapChatMessages(List<ChatMessage> messages) {
//     return messages.map((chatMessage) {
//       if (chatMessage.isUserMessage) {
//         return types.TextMessage(
//           author: _user,
//           createdAt: chatMessage.timestamp.millisecondsSinceEpoch,
//           id: chatMessage.id,
//           text: chatMessage.content,
//         );
//       } else {
//         return types.TextMessage(
//           author: _bot,
//           createdAt: chatMessage.timestamp.millisecondsSinceEpoch,
//           id: chatMessage.id,
//           text: chatMessage.content,
//         );
//       }
//     }).toList();
//   }

//   void _handleSendMessage(
//       BuildContext context, types.PartialText message, String threadId) {
//     print(threadId);
//     final chatMessage = ChatMessage(
//       id: const Uuid().v4(),
//       content: message.text,
//       isUserMessage: true,
//       timestamp: DateTime.now(),
//     );

//     context
//         .read<ChatBloc>()
//         .add(SendMessageEvent(threadId: threadId, chatMessage: chatMessage));
//   }

//   ChatMessage? getLastMessage(List<ChatMessage> messages) {
//     if (messages.isEmpty) {
//       return null;
//     }
//     return messages.last;
//   }

//   DateTime? getLastMessageDate(List<ChatMessage> messages) {
//     final lastMessage = getLastMessage(messages);
//     return lastMessage?.timestamp;
//   }

//   bool _hasApiKey(Map<String, String> apiKeys) {
//     for (ServiceName serviceName in ServiceName.values) {
//       if (apiKeys[serviceName.name] != null &&
//           apiKeys[serviceName.name]!.isNotEmpty) {
//         return true;
//       }
//     }
//     return false;
//   }
// }
