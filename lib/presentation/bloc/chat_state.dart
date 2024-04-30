part of 'chat_bloc.dart';

class ChatState {
  final Thread? thread;
  final List<Thread> threads; // Add a list of threads

  ChatState(
      {this.thread, this.threads = const []}); // Initialize the threads list

  factory ChatState.initial() {
    return ChatState(
        thread: Thread(id: Uuid().v4(), name: "New Chat", messages: []),
        threads: []); // Initialize the threads list
  }

  ChatState copyWith({Thread? thread, List<Thread>? threads}) {
    return ChatState(
        thread: thread ?? this.thread, threads: threads ?? this.threads);
  }
}
