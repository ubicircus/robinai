import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
import 'package:hive_flutter/hive_flutter.dart';
// import 'package:robin_ai/data/datasources/chat_local.dart';
import 'package:robin_ai/data/datasources/chat_network.dart';
import 'package:robin_ai/data/model/thread_model.dart';
import 'package:robin_ai/data/repository/chat_repository.dart';
import 'package:robin_ai/domain/usecases/threads/get_last_thread_id_usecase.dart';
import 'package:robin_ai/domain/usecases/threads/get_thread_details_by_id_usecase.dart';
import 'package:robin_ai/domain/usecases/threads/get_threads_list_usecase.dart';

// import 'presentation/provider/chat_provider.dart';
import 'presentation/pages/main_page.dart';
// import 'presentation/provider/theme_provider.dart';
import 'domain/usecases/messages/send_message.dart';
// import 'domain/usecases/messages/fetch_all_messages.dart';
import 'domain/entities/app_themes.dart';
import 'data/model/chat_message_local_model.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'presentation/bloc/chat_bloc.dart';
import 'data/datasources/chat_local.dart';

void main() async {
  // Ensure initialized.
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive and open box.
  await Hive.initFlutter();

  // Register the adapter
  Hive.registerAdapter(ChatMessageLocalAdapter());
  Hive.registerAdapter(ThreadModelAdapter());
  Hive.registerAdapter(MessageAdapter());

  // await Hive.openBox('chatHistory');
  // await Hive.openBox('threads');

  // Create an instance of ChatNetworkDataSource
  final chatNetworkDataSource = ChatNetworkDataSource();
  final chatLocalDataSource = ChatLocalDataSource();

  // Create an instance of ChatRepository
  final chatRepository = ChatRepository(
    networkDataSource: chatNetworkDataSource,
    chatLocalDataSource: chatLocalDataSource,
  );

  // Create an instance of SendMessageUseCase
  final sendMessageUseCase = SendMessageUseCase(chatRepository: chatRepository);
  final getLastThreadIdUseCase =
      GetLastThreadIdUseCase(repository: chatRepository);
  final getThreadDetailsByIdUseCase =
      GetThreadDetailsByIdUseCase(chatRepository: chatRepository);
  final getThreadListUseCase = GetThreadListUseCase(repository: chatRepository);

  runApp(BlocProvider<ChatBloc>(
    create: (context) => ChatBloc(
      sendMessageUseCase: sendMessageUseCase,
      chatRepository: chatRepository,
      getLastThreadIdUseCase: getLastThreadIdUseCase,
      getThreadDetailsByIdUseCase: getThreadDetailsByIdUseCase,
      getThreadListUseCase: getThreadListUseCase,
    ),
    child: MyApp(),
  ));
}

class MyApp extends StatefulWidget {
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  late ChatLocalDataSource chatLocalDataSource;

  @override
  void initState() {
    super.initState();
    chatLocalDataSource = ChatLocalDataSource();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    chatLocalDataSource.closeBox(); // Close Hive box
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.detached) {
      chatLocalDataSource
          .closeBox(); // Close Hive box when app is fully terminated
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Robin AI Assistant',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.teal,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        visualDensity: VisualDensity.adaptivePlatformDensity,
        textTheme: ThemeData.light().textTheme.copyWith(
              bodyText1: TextStyle(color: Colors.teal.shade600),
              bodyText2: TextStyle(color: Colors.teal.shade600),
            ),
      ),
      home: ChatPage(),
      routes: {},
    );
  }
}
