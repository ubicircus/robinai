import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import '../../lib/domain/usecases/messages/send_message.dart';
import '../../lib/domain/entities/chat_message_class.dart';
import '../../lib/data/repository/chat_message_repository.dart';

class MockChatRepository extends Mock implements ChatRepository {}

final message = ChatMessage(
  id: '1',
  isUserMessage: true,
  content: 'Hello, how are you?',
  timestamp: DateTime.now(),
);

final responseMessage = ChatMessage(
  id: '2',
  isUserMessage: false,
  content: 'I am doing well, thanks!',
  timestamp: DateTime.now(),
);

void main() {
  group('SendMessageUseCase', () {
    late SendMessageUseCase sendMessageUseCase;
    late MockChatRepository mockChatRepository;

    setUp(() {
      mockChatRepository = MockChatRepository();
      sendMessageUseCase =
          SendMessageUseCase(chatRepository: mockChatRepository);
    });

    test('should return the response message from the repository', () async {
      // Arrange
      when(mockChatRepository.sendChatMessage(message))
          .thenAnswer((_) async => responseMessage);

      // Act
      final result = await sendMessageUseCase.call(message);

      // Assert
      expect(result, responseMessage);
      verify(mockChatRepository.sendChatMessage(message)).called(1);
      verifyNoMoreInteractions(mockChatRepository);
    });
  });
}
