import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:robin_ai/data/repository/chat_repository.dart';
import 'package:robin_ai/domain/entities/chat_message_class.dart';
import 'package:robin_ai/domain/usecases/messages/send_message.dart';

part 'chat_event.dart';
part 'chat_state.dart';

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  final SendMessageUseCase sendMessageUseCase;
  final ChatRepository chatRepository;

  ChatBloc({required this.sendMessageUseCase, required this.chatRepository})
      : super(ChatState.initial()) {
    on<SendMessageEvent>(_handleSendMessage);
    on<LoadMessagesEvent>(_handleLoadMessages);
  }

  void _handleSendMessage(
      SendMessageEvent event, Emitter<ChatState> emit) async {
    try {
      final userMessage = event.chatMessage;

      // write user message
      List<ChatMessage> updatedMessages = List<ChatMessage>.from(state.messages)
        ..insert(0, userMessage);
      emit(state.copyWith(messages: updatedMessages));

      //send the message
      final responseMessage = await sendMessageUseCase.call(userMessage);

      //write response message
      updatedMessages = List<ChatMessage>.from(state.messages)
        ..insert(0, responseMessage);
      emit(state.copyWith(messages: updatedMessages));
    } catch (e) {
      // Handle error case here
      emit(state); // Keep the state unchanged in case of an error
    }
  }

  void _handleLoadMessages(
      LoadMessagesEvent event, Emitter<ChatState> emit) async {
    final messages = await _loadMessagesFromSource();
    emit(state.copyWith(messages: messages));
  }

  Future<List<ChatMessage>> _loadMessagesFromSource() async {
    // Implement actual logic to load messages
    return []; // For demonstration, return an empty list
  }
}
