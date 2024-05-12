part of 'chat_bloc.dart';

class ChatState {
  final Thread? thread;
  final List<Thread> threads; // Add a list of threads
  final ServiceName serviceName;
  final String modelName;
  final List<String> modelsAvailable;
  final ContextModel context;

  ChatState({
    this.thread,
    this.threads = const [],
    this.serviceName = ServiceName.openai,
    this.modelName = 'gpt-3.5-turbo-0613',
    this.modelsAvailable = const ['gpt-3.5-turbo-0613'],
    ContextModel? context,
  }) : context = context ??
            ContextModel(
              id: '1',
              name: 'Basic Assistant',
              text: 'You are a helpful assistant',
              formatSpecifier: '',
              actionUrl: '',
              isActionActive: false,
              isContextActive: true,
              isDefault: true,
            );

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
    ContextModel? context,
  }) {
    return ChatState(
      thread: thread ?? this.thread,
      threads: threads ?? this.threads,
      serviceName: serviceName ?? this.serviceName,
      modelName: modelName ?? this.modelName,
      modelsAvailable: modelsAvailable ?? this.modelsAvailable,
      context: context ?? this.context,
    );
  }
}
