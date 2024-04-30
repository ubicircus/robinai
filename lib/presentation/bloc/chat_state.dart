part of 'chat_bloc.dart';

class ChatState {
  final Thread? thread;

  ChatState({this.thread});

  factory ChatState.initial() {
    return ChatState(
        thread: Thread(id: Uuid().v4(), name: "New Chat", messages: []));
  }

  ChatState copyWith({Thread? thread}) {
    return ChatState(thread: thread ?? this.thread);
  }
}
