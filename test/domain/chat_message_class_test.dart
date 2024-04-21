import 'package:flutter_test/flutter_test.dart';
import '../../lib/domain/entities/chat_message_class.dart';

void main() {
  group('ChatMessage', () {
    test('Should create a valid ChatMessage object', () {
      final message = ChatMessage(
        id: '2',
        content: 'Hello!',
        isUserMessage: true,
        timestamp: DateTime.now(),
      );

      expect(message.id, '1');
      expect(message.content, 'Hello!');
      expect(message.isUserMessage, true);
      expect(message.timestamp, isA<DateTime>());
    });
  });
}
