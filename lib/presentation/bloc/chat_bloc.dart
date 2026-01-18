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
import 'package:robin_ai/presentation/config/context/model/context_model.dart';
import 'package:robin_ai/presentation/config/services/app_settings_service.dart';
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
    on<SelectDefaultContext>(_handleSelectContext);
    on<CalendarEventStatusEvent>(_handleCalendarEventStatus);
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
          updatedThread.messages.reversed.toList(),
          state.context);

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
      print('🚀 InitializeAppEvent: Starting app initialization...');

      // Get available service providers (those with API keys)
      final appSettingsService = AppSettingsService();
      final apiKeys = await appSettingsService.readApiKeys();

      print('🔑 API Keys found:');
      apiKeys.forEach((key, value) {
        print('  - $key: ${value.isNotEmpty ? "✅ PRESENT" : "❌ EMPTY"}');
      });

      // Determine first available service provider
      // Priority: gemini > groq > perplexity > dyrektywa > openai
      final preferredOrder = [
        ServiceName.gemini,
        ServiceName.groq,
        ServiceName.perplexity,
        ServiceName.dyrektywa,
        ServiceName.openai,
      ];

      ServiceName? availableService;
      for (final service in preferredOrder) {
        if (apiKeys[service.name]?.isNotEmpty ?? false) {
          availableService = service;
          print('✅ Selected service provider: ${service.name}');
          break;
        }
      }

      // Use found service or keep current
      final serviceName = availableService ?? state.serviceName;

      if (availableService == null) {
        print('⚠️ No API keys found, using default: ${state.serviceName.name}');
      }

      // Fetch models for the selected service
      print('📡 Fetching models for: ${serviceName.name}');
      final modelsAvailable = await getModelsUseCase.call(serviceName);
      print('📋 Models received: $modelsAvailable');

      final selectedModel =
          modelsAvailable.isNotEmpty ? modelsAvailable.first : state.modelName;
      print('🎯 Selected model: $selectedModel');

      emit(state.copyWith(
        serviceName: serviceName,
        modelsAvailable: modelsAvailable,
        modelName: selectedModel,
      ));

      print('✅ Initialization complete!');
    } catch (e) {
      // Handle error during app initialization
      print('❌ Error during initialization: $e');
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

  _handleSelectContext(
      SelectDefaultContext event, Emitter<ChatState> emit) async {
    final ContextModel context = event.context;
    emit(state.copyWith(context: context));
  }

  void _handleCalendarEventStatus(
      CalendarEventStatusEvent event, Emitter<ChatState> emit) async {
    try {
      final threadId = state.thread?.id ?? "";
      
      if (threadId.isEmpty) {
        print('CalendarEventStatusEvent: No active thread');
        return;
      }

      final updatedThread = state.thread ??
          Thread(id: threadId, messages: [], name: "Thread name");

      // Only add follow-up message for failures/denials, not for success
      // The followUpMessage from CalendarEventService is already filtered
      updatedThread.messages.insert(0, event.followUpMessage);
      emit(state.copyWith(thread: updatedThread));

      // Only send to LLM for failures/denials, not for success
      // This prevents duplicate confirmations
      if (event.status == 'denied' || event.status == 'failed') {
        final systemMessage = ChatMessage(
          id: const Uuid().v4(),
          content: _buildCalendarStatusMessage(event),
          isUserMessage: true, // This represents user action/feedback
          timestamp: DateTime.now(),
        );

        updatedThread.messages.insert(0, systemMessage);
        emit(state.copyWith(thread: updatedThread));

        // Get LLM response to the status update
        final responseMessage = await sendMessageUseCase.call(
          threadId,
          systemMessage,
          state.serviceName,
          state.modelName,
          updatedThread.messages.reversed.toList(),
          state.context,
        );

        updatedThread.messages.insert(0, responseMessage);
        emit(state.copyWith(thread: updatedThread));
      }
    } catch (e) {
      print('Error handling calendar event status: $e');
      // Don't emit error state, just log it
    }
  }

  String _buildCalendarStatusMessage(CalendarEventStatusEvent event) {
    switch (event.status) {
      case 'denied':
        return 'Calendar permission was denied for the event "${event.eventTitle}". '
            'I cannot add this event to your calendar without permission. '
            'Would you like to try again, or would you prefer to add it manually?';
      case 'failed':
        return 'Failed to add the event "${event.eventTitle}" to your calendar. '
            '${event.error != null ? "Error: ${event.error}" : ""} '
            'Would you like to try again?';
      default:
        return 'Calendar event status update: ${event.status}';
    }
  }
}
