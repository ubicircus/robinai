part of 'chat_bloc.dart';

class ChatState {
  final Thread? thread;
  final List<Thread> threads; // Add a list of threads
  final ServiceName serviceName;
  final String modelName;
  final List<String> modelsAvailable;

  ChatState({
    this.thread,
    this.threads = const [],
    this.serviceName = ServiceName.openai,
    this.modelName = 'gpt-3.5-turbo-0613',
    this.modelsAvailable = const ['gpt-3.5-turbo-0613'],
  });

  factory ChatState.initial() {
    return ChatState(
        thread: Thread(id: Uuid().v4(), name: "New Chat", messages: []),
        threads: []); // Initialize the threads list
  }

  ChatState copyWith({
    Thread? thread,
    List<Thread>? threads,
    ServiceName? serviceName,
    String? modelName,
    List<String>? modelsAvailable,
  }) {
    return ChatState(
      thread: thread ?? this.thread,
      threads: threads ?? this.threads,
      serviceName: serviceName ?? this.serviceName,
      modelName: modelName ?? this.modelName,
      modelsAvailable: modelsAvailable ?? this.modelsAvailable,
    );
  }
}
