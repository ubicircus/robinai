import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:robin_ai/data/datasources/chat_local.dart';
import 'package:robin_ai/data/datasources/chat_network.dart';
import 'package:robin_ai/data/repository/chat_repository.dart';

import 'presentation/provider/chat_provider.dart';
import 'presentation/pages/main_page.dart';
import 'presentation/pages/settings_page.dart';
import 'presentation/provider/theme_provider.dart';
import 'domain/usecases/send_message.dart';
import 'domain/usecases/fetch_all_messages.dart';
import 'domain/entities/app_themes.dart';
import 'data/model/chat_message_model.dart';

void main() async {
  // Ensure initialized.
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive and open box.
  await Hive.initFlutter();

  // Register the adapter
  Hive.registerAdapter(ChatMessageClassAdapter());

  await Hive.openBox('chatHistory');
  await Hive.openBox('threads');

  // Move the instantiation to the main function.
  final chatLocalDataSource = ChatLocalDataSource();
  final chatNetworkDataSource = ChatNetworkDataSource();
  final chatRepository = ChatRepository(
    localDataSource: chatLocalDataSource,
    networkDataSource: chatNetworkDataSource,
  );
  final sendMessageUseCase = SendMessageUseCase(chatRepository: chatRepository);
  final fetchAllMessagesUseCase =
      FetchAllMessagesUseCase(chatRepository: chatRepository);

  runApp(MyApp(
    sendMessageUseCase: sendMessageUseCase,
    fetchAllMessagesUseCase: fetchAllMessagesUseCase,
  ));
}

class MyApp extends StatelessWidget {
  final SendMessageUseCase sendMessageUseCase;
  final FetchAllMessagesUseCase fetchAllMessagesUseCase;

  MyApp(
      {required this.sendMessageUseCase,
      required this.fetchAllMessagesUseCase});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<ThemeProvider>(
            create: (context) => ThemeProvider(AppThemes.tealTheme)),
        ChangeNotifierProvider<ChatProvider>(
            create: (context) => ChatProvider(
                sendMessage: sendMessageUseCase,
                fetchAllMessages: fetchAllMessagesUseCase)),
      ],
      child: Builder(
        builder: (context) {
          final themeProvider = Provider.of<ThemeProvider>(context);
          return MaterialApp(
            title: 'Flutter Smart Application',
            debugShowCheckedModeBanner: false,
            theme: ThemeData(
              primarySwatch: Colors.teal, // Setting the primary swatch to Teal
              colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
              visualDensity: VisualDensity.adaptivePlatformDensity,
              textTheme: ThemeData.light().textTheme.copyWith(
                    bodyLarge: TextStyle(color: Colors.teal.shade600),
                    bodyMedium: TextStyle(color: Colors.teal.shade600),
                    bodySmall: TextStyle(color: Colors.teal.shade600),
                    // Define other text styles like `headline1`, `headline2`,... if needed
                  ),
            ),
            home: ChatPage(),
            routes: {
              SettingsPage.routeName: (context) => SettingsPage(),
            },
          );
        },
      ),
    );
  }
}
