import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:robin_ai/data/datasources/chat_local.dart';
import 'package:robin_ai/domain/entities/chat_message_class.dart';
import 'package:robin_ai/data/model/chat_message_local_model.dart';
import 'package:robin_ai/domain/entities/exceptions.dart';
import 'package:mockito/mockito.dart';
import 'package:path_provider/path_provider.dart';

class MockDirectory extends Mock implements Directory {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const MethodChannel('plugins.flutter.io/path_provider')
      .setMockMethodCallHandler((MethodCall methodCall) async {
    if (methodCall.method == 'getApplicationDocumentsDirectory') {
      final path = 'path/to/directory';
      return path;
    }
  });
  group('ChatLocalDataSource Tests', () {
    late ChatLocalDataSource dataSource;
    late Box<ChatMessage> box;

    setUpAll(() async {
      Hive.registerAdapter(ChatMessageModelAdapter());
      dataSource = ChatLocalDataSource();
      await dataSource.initialize();
    });

    tearDownAll(() async {
      await Hive.deleteBoxFromDisk('chatHistory');
      await Hive.close();
    });

    test('Initialize ChatLocalDataSource', () {
      expect(dataSource, isNotNull);
    });

    test('Add and Retrieve ChatMessage', () async {
      final chatMessage = ChatMessage(
        id: '001',
        content: 'Hello, World!',
        isUserMessage: true,
        timestamp: DateTime.now(),
      );

      await dataSource.addChatMessage(chatMessage);

      final retrievedMessages = dataSource.getChatMessages();
      expect(retrievedMessages.first.id, equals(chatMessage.id));
      expect(retrievedMessages.first.content, equals(chatMessage.content));
      expect(retrievedMessages.first.isUserMessage,
          equals(chatMessage.isUserMessage));
      expect(retrievedMessages.first.timestamp, chatMessage.timestamp);
    });
    // test('Close Box', () async {
    //   await dataSource.closeBox();
    //   expect(dataSource.isClosed, isTrue);
    // });

    test('Handling Exceptions', () async {
      await dataSource.closeBox(); // Closing to simulate initialization failure
      expect(
          () async => await dataSource.addChatMessage(ChatMessage(
              id: '002',
              content: 'TestMessage',
              isUserMessage: false,
              timestamp: DateTime.now())),
          throwsA(isA<
              InitializationException>())); // Checking if proper exception is thrown after the box is closed
    });
    test('Handling SaveDataException', () async {
      when(dataSource.addChatMessage(any))
          .thenThrow(Exception('Failed to Save'));

      expect(
        () async => await dataSource.addChatMessage(ChatMessage(
            id: '004',
            content: 'Exception test',
            isUserMessage: true,
            timestamp: DateTime.now())),
        throwsA(isA<SaveDataException>()),
      );
    });
    // Add more tests for exception handling
  });
}
