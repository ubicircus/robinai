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

class LoadThreadsEvent extends ChatEvent {}

class ClearChatEvent extends ChatEvent {}

class SelectServiceProviderEvent extends ChatEvent {
  final ServiceName serviceName;

  SelectServiceProviderEvent({required this.serviceName});
}

class SelectModelEvent extends ChatEvent {
  final String modelName;

  SelectModelEvent({required this.modelName});
}

class GetModelsEvent extends ChatEvent {
  final ServiceName serviceName;
  GetModelsEvent({required this.serviceName});
}

class SelectDefaultContext extends ChatEvent {
  final ContextModel context;
  SelectDefaultContext({required this.context});
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
