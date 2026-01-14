import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
// import 'package:provider/provider.dart';
import 'package:hive_flutter/hive_flutter.dart';
// import 'package:robin_ai/data/datasources/chat_local.dart';
import 'package:robin_ai/data/datasources/chat_network.dart';
import 'package:robin_ai/data/datasources/llm_models/model_factory.dart';

import 'package:robin_ai/data/model/thread_model.dart';
import 'package:robin_ai/data/repository/chat_message_repository.dart';
import 'package:robin_ai/data/repository/models_repository.dart';
import 'package:robin_ai/data/repository/thread_repository.dart';
import 'package:robin_ai/domain/usecases/get_models_use_case.dart';
import 'package:robin_ai/domain/usecases/threads/get_last_thread_id_usecase.dart';
import 'package:robin_ai/domain/usecases/threads/get_thread_details_by_id_usecase.dart';
import 'package:robin_ai/domain/usecases/threads/get_threads_list_usecase.dart';
import 'package:robin_ai/presentation/config/context/app_settings_context_config.dart';
import 'package:robin_ai/presentation/config/context/model/context_model.dart';
import 'package:robin_ai/presentation/config/services/app_settings_service.dart';
import 'package:robin_ai/presentation/config/services/model/service_model.dart';
import 'package:robin_ai/presentation/pages/settings_page.dart';
import 'package:robin_ai/presentation/genui/gen_ui_test_page.dart';
import 'package:robin_ai/presentation/pages/dashboard_page.dart';

// import 'presentation/provider/chat_provider.dart';
// import 'presentation/provider/theme_provider.dart';
import 'domain/usecases/messages/send_message.dart';
// import 'domain/usecases/messages/fetch_all_messages.dart';
import 'data/model/chat_message_local_model.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'presentation/bloc/chat_bloc.dart';
import 'data/datasources/chat_local.dart';

void main() async {
  // Ensure initialized.
  WidgetsFlutterBinding.ensureInitialized();
  const secureStorage = FlutterSecureStorage();
  var containsEncryptionKey =
      await secureStorage.containsKey(key: 'encryptionKey');
  if (!containsEncryptionKey) {
    var key = Hive.generateSecureKey();
    await secureStorage.write(
        key: 'encryptionKey', value: base64UrlEncode(key));
  }

  // Initialize Hive and open box.
  await Hive.initFlutter();

  // Register the adapter
  Hive.registerAdapter(ChatMessageLocalAdapter());
  Hive.registerAdapter(ThreadModelAdapter());
  Hive.registerAdapter(MessageAdapter());
  Hive.registerAdapter(ServiceModelAdapter());
  Hive.registerAdapter(ContextModelAdapter());

  // await Hive.openBox('chatHistory');
  // await Hive.openBox('threads');

  // Create an instance of ChatNetworkDataSource
  final chatNetworkDataSource =
      ChatNetworkDataSource(modelFactory: ModelFactory());
  final chatLocalDataSource = ChatLocalDataSource();

  // Create an instance of ChatRepository
  final chatRepository = ChatMessageRepository(
    chatNetworkDataSource: chatNetworkDataSource,
    chatLocalDataSource: chatLocalDataSource,
  );
  final threadRepository =
      ThreadRepository(chatLocalDataSource: chatLocalDataSource);
  final modelsRepository =
      ModelsRepository(chatNetworkDataSource: chatNetworkDataSource);

  // Create an instance of SendMessageUseCase
  final sendMessageUseCase = SendMessageUseCase(chatRepository: chatRepository);
  final getLastThreadIdUseCase =
      GetLastThreadIdUseCase(repository: threadRepository);
  final getThreadDetailsByIdUseCase =
      GetThreadDetailsByIdUseCase(threadRepository: threadRepository);
  final getThreadListUseCase =
      GetThreadListUseCase(repository: threadRepository);
  final getModelsUseCase = GetModelsUseCase(modelsRepository: modelsRepository);

  runApp(BlocProvider<ChatBloc>(
    create: (context) => ChatBloc(
      sendMessageUseCase: sendMessageUseCase,
      chatRepository: chatRepository,
      getLastThreadIdUseCase: getLastThreadIdUseCase,
      getThreadDetailsByIdUseCase: getThreadDetailsByIdUseCase,
      getThreadListUseCase: getThreadListUseCase,
      getModelsUseCase: getModelsUseCase,
    ),
    child: const MyApp(),
  ));
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  late ChatLocalDataSource chatLocalDataSource;
  late AppSettingsService appSettingsService;
  late ContextModelService contextModelService;

  @override
  void initState() {
    super.initState();
    chatLocalDataSource = ChatLocalDataSource();
    appSettingsService = AppSettingsService();
    appSettingsService.initAppSettings();
    contextModelService = ContextModelService();
    contextModelService.initContextModelService();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    chatLocalDataSource.closeBox(); // Close Hive box
    appSettingsService.closeBox();
    contextModelService.closeBox();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.detached) {
      chatLocalDataSource
          .closeBox(); // Close Hive box when app is fully terminated
      appSettingsService.closeBox();
      contextModelService.closeBox();
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
              bodyLarge: TextStyle(color: Colors.teal.shade600),
              bodyMedium: TextStyle(color: Colors.teal.shade600),
            ),
      ),
      home: const DashboardPage(),
      routes: {
        '/settings': (context) => SettingsPage(),
        '/genui-test': (context) => const GenUiTestPage(),
      },
    );
  }
}
