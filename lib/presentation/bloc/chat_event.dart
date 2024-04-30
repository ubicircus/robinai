part of 'chat_bloc.dart';

abstract class ChatEvent {}

class SendMessageEvent extends ChatEvent {
  final ChatMessage chatMessage;

  SendMessageEvent({required this.chatMessage});
}

class LoadMessagesEvent extends ChatEvent {}

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
