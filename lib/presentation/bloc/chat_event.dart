part of 'chat_bloc.dart';

abstract class ChatEvent {}

class InitializeAppEvent extends ChatEvent {}

class LoadMessagesEvent extends ChatEvent {
  final String threadId;

  LoadMessagesEvent({required this.threadId});
}

class SendMessageEvent extends ChatEvent {
  final ChatMessage chatMessage;
  final String threadId;

  SendMessageEvent({required this.chatMessage, required this.threadId});
}

// chat_state.dart

// class ChatState {
//   final List<ChatMessage> messages;

//   ChatState({required this.messages});

//   factory ChatState.initial() {
//     return ChatState(messages: []);
//   }

//   ChatState copyWith({List<ChatMessage>? messages}) {
//     return ChatState(messages: messages ?? this.messages);
//   }
// }
