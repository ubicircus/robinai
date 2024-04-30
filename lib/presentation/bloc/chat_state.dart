part of 'chat_bloc.dart';

class ChatState {
  final List<ChatMessage> messages;

  ChatState({required this.messages});

  factory ChatState.initial() {
    return ChatState(messages: []);
  }

  ChatState copyWith({List<ChatMessage>? messages}) {
    return ChatState(messages: messages ?? this.messages);
  }
}
