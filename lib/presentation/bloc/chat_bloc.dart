import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:robin_ai/core/service_names.dart';
import 'package:robin_ai/data/repository/chat_message_repository.dart';
import 'package:robin_ai/domain/entities/chat_message_class.dart';
import 'package:robin_ai/domain/entities/thread_class.dart';
import 'package:robin_ai/domain/usecases/get_models_use_case.dart';
import 'package:robin_ai/domain/usecases/messages/send_message.dart';
import 'package:robin_ai/domain/usecases/threads/get_last_thread_id_usecase.dart';
import 'package:robin_ai/domain/usecases/threads/get_thread_details_by_id_usecase.dart';
import 'package:robin_ai/domain/usecases/threads/get_threads_list_usecase.dart';
import 'package:uuid/uuid.dart';

part 'chat_event.dart';
part 'chat_state.dart';

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  final SendMessageUseCase sendMessageUseCase;
  final ChatMessageRepository chatRepository;
  final GetLastThreadIdUseCase getLastThreadIdUseCase;
  final GetThreadDetailsByIdUseCase getThreadDetailsByIdUseCase;
  final GetThreadListUseCase getThreadListUseCase;
  final GetModelsUseCase getModelsUseCase;

  ChatBloc({
    required this.sendMessageUseCase,
    required this.chatRepository,
    required this.getLastThreadIdUseCase,
    required this.getThreadDetailsByIdUseCase,
    required this.getThreadListUseCase,
    required this.getModelsUseCase,
  }) : super(ChatState.initial()) {
    on<SendMessageEvent>(_handleSendMessage);
    on<InitializeAppEvent>(_handleInitializeApp);
    on<LoadThreadsEvent>(_handleLoadThreads);
    on<LoadMessagesEvent>(_handleLoadMessages);
    on<ClearChatEvent>(_clearChatWindow);
    on<SelectServiceProviderEvent>(_handleSelectServiceProvider);
    on<SelectModelEvent>(_handleSelectModel);
    on<GetModelsEvent>(_getModels);
  }

  void _handleSendMessage(
      SendMessageEvent event, Emitter<ChatState> emit) async {
    try {
      final userMessage = event.chatMessage;
      final threadId = state.thread?.id ??
          ""; // Get the thread ID from the state or set to an empty string if not available

      // Check if the thread ID is available
      if (threadId.isEmpty) {
        // Handle missing thread ID case
        print('thread id is empty');
        return;
      }

      // Get the current thread from the state or create a new one if not available
      final updatedThread = state.thread ??
          Thread(id: threadId, messages: [], name: "Thread name");

      // Add the user message to the thread
      updatedThread.messages.insert(0, userMessage);

      emit(state.copyWith(thread: updatedThread));

      // Send the message
      final responseMessage = await sendMessageUseCase.call(
        threadId,
        userMessage,
        state.serviceName,
        state.modelName,
        updatedThread.messages,
      );

      // Add the response message to the thread
      updatedThread.messages.insert(0, responseMessage);

      emit(state.copyWith(thread: updatedThread));
    } catch (e) {
      // Handle error case here
      emit(state); // Keep the state unchanged in case of an error
    }
  }

  // void _handleLoadMessages(
  //     LoadMessagesEvent event, Emitter<ChatState> emit) async {
  //   final messages = await _loadMessagesFromSource();
  //   emit(state.copyWith(messages: messages));
  // }

  // Future<List<ChatMessage>> _loadMessagesFromSource() async {
  //   // Implement actual logic to load messages
  //   return []; // For demonstration, return an empty list
  // }

  void _handleInitializeApp(
      InitializeAppEvent event, Emitter<ChatState> emit) async {
    try {
      // final lastThreadId = await getLastThreadIdUseCase.call();
      // print('Last Thread ID: $lastThreadId');

      // final lastThread =
      //     await getThreadDetailsByIdUseCase.call(threadId: lastThreadId);
      // print('Last Thread Details: $lastThread');

      // final updatedThread = Thread(
      //     id: lastThread.id,
      //     messages: lastThread.messages,
      //     name: lastThread.name);

      // emit(state.copyWith(thread: updatedThread)); // Update with current thread
      final modelsAvailable = await getModelsUseCase.call(state.serviceName);
      emit(state.copyWith(modelsAvailable: modelsAvailable));
    } catch (e) {
      // Handle error during app initialization
      rethrow;
    }
  }

  void _handleLoadThreads(
      LoadThreadsEvent event, Emitter<ChatState> emit) async {
    try {
      final threads = await getThreadListUseCase.call();
      emit(state.copyWith(threads: threads));
    } catch (e) {
      // Handle error case here
      emit(state); // Keep the state unchanged in case of an error
    }
  }

  void _handleLoadMessages(
      LoadMessagesEvent event, Emitter<ChatState> emit) async {
    try {
      final threadId = event.threadId;
      final thread = await getThreadDetailsByIdUseCase.call(threadId: threadId);
      emit(state.copyWith(thread: thread));
    } catch (e) {
      rethrow;
    }
  }

  void _clearChatWindow(ClearChatEvent event, Emitter<ChatState> emit) async {
    emit(state.copyWith(
      thread: Thread(id: Uuid().v4(), name: "New Chat", messages: []),
    ));
  }

  void _handleSelectServiceProvider(
      SelectServiceProviderEvent event, Emitter<ChatState> emit) async {
    final serviceName = event.serviceName;
    if (serviceName != state.serviceName) {
      try {
        emit(state.copyWith(serviceName: serviceName));
        final modelsAvailable = await getModelsUseCase.call(state.serviceName);
        emit(state.copyWith(modelsAvailable: modelsAvailable));
        emit(state.copyWith(modelName: modelsAvailable.first));
      } catch (e) {
        rethrow;
      }
    }
  }

  void _handleSelectModel(SelectModelEvent event, Emitter<ChatState> emit) {
    final modelName = event.modelName;
    emit(state.copyWith(modelName: modelName));
  }

  void _getModels(GetModelsEvent event, Emitter<ChatState> emit) async {
    final ServiceName serviceName = event.serviceName;

    try {
      final modelsAvailable = await getModelsUseCase.call(serviceName);
      emit(state.copyWith(modelsAvailable: modelsAvailable));
    } catch (e) {
      rethrow;
    }
  }
}
