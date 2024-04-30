import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:robin_ai/data/model/chat_message_network_mapper.dart';
import 'package:robin_ai/domain/entities/chat_message_class.dart';
import 'package:robin_ai/data/datasources/chat_network.dart';
import 'package:robin_ai/data/repository/chat_repository.dart';
import 'package:robin_ai/core/error_messages.dart';
import 'package:mockito/annotations.dart';

// class MockChatNetworkDataSource extends Mock implements ChatNetworkDataSource {}

// class MockChatLocalDataSource extends Mock implements ChatLocalDataSource {}

// Generate mocks for ChatNetworkDataSource and ChatLocalDataSource
@GenerateMocks([ChatNetworkDataSource])
import 'chat_repository_test.mocks.dart';

void main() {
  late MockChatNetworkDataSource mockNetworkDataSource;
  // late MockChatLocalDataSource mockLocalDataSource;
  late ChatRepository repository;

  setUp(() {
    mockNetworkDataSource = MockChatNetworkDataSource();
    // mockLocalDataSource = MockChatLocalDataSource();
    repository = ChatRepository(
      networkDataSource: mockNetworkDataSource,
      // localDataSource: mockLocalDataSource
    );
  });

  group('sendChatMessage', () {
    final tMessage = ChatMessage(
        id: '1',
        content: 'Hello',
        timestamp: DateTime.now(),
        isUserMessage: true);

    test('should send the initial message and then save the response',
        () async {
      // Arrange
      ChatMessage responseMessage = ChatMessage(
          id: '2',
          content: 'Response',
          timestamp: DateTime.now(),
          isUserMessage: true);
      when(mockNetworkDataSource.sendChatMessage(any)).thenAnswer((_) async =>
          Future.value(ChatMessageMapper.toNetworkModel(responseMessage)));

      // Act
      final result = await repository.sendChatMessage(tMessage);

      // Assert

      verify(mockNetworkDataSource
              .sendChatMessage(ChatMessageMapper.toNetworkModel(tMessage)))
          .called(1);
      expect(result, equals(responseMessage));
    });

    test('should throw an error when network fails', () async {
      // Arrange
      when(mockNetworkDataSource.sendChatMessage(any))
          .thenThrow(ErrorMessages.sendNetworkFailed);

      // Act & Assert
      expect(
          () async => await repository.sendChatMessage(tMessage),
          throwsA(
              isInstanceOf<String>())); // Assuming ErrorMessages are strings
      verifyNoMoreInteractions(mockNetworkDataSource);
    });
  });
}
