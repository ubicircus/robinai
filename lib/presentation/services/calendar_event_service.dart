import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:robin_ai/presentation/bloc/chat_bloc.dart';
import 'package:robin_ai/domain/entities/chat_message_class.dart';
import 'package:uuid/uuid.dart';

/// Service to handle calendar event status changes and notify the chat bloc
class CalendarEventService {
  static final CalendarEventService _instance = CalendarEventService._internal();
  factory CalendarEventService() => _instance;
  static CalendarEventService get instance => _instance;
  CalendarEventService._internal();

  BuildContext? _chatContext;

  /// Set the chat context so we can access ChatBloc
  void setChatContext(BuildContext context) {
    _chatContext = context;
  }

  /// Notify about a calendar event status change
  void notifyStatusChange({
    required String eventId,
    required String status,
    String? error,
    required String eventTitle,
  }) {
    if (_chatContext == null) {
      debugPrint('CalendarEventService: No chat context set, cannot send follow-up message');
      return;
    }

    try {
      final chatBloc = _chatContext!.read<ChatBloc>();
      final state = chatBloc.state;

      if (state.thread == null) {
        debugPrint('CalendarEventService: No active thread');
        return;
      }

      // Only send notifications for failures/denials, not for success
      // With device_calendar, we can detect success, but we don't need to spam the chat
      String messageContent;
      switch (status) {
        case 'denied':
          messageContent = 'Calendar permission was denied for the event "$eventTitle". '
              'You can retry by tapping the "Retry" button on the event card, or enable calendar permissions in your device settings.';
          break;
        case 'failed':
          messageContent = 'Failed to add the event "$eventTitle" to your calendar. '
              '${error != null ? "Error: $error" : ""} You can retry by tapping the "Retry" button on the event card.';
          break;
        case 'created':
        case 'granted':
        case 'pending':
        case 'requesting':
        default:
          return; // Don't send message for success or pending/requesting states
      }

      // Create a user message that represents the system's response to the permission action
      final followUpMessage = ChatMessage(
        id: const Uuid().v4(),
        content: messageContent,
        isUserMessage: false, // This is an AI/system response
        timestamp: DateTime.now(),
      );

      // Send this as a follow-up message to the LLM
      // We'll create a special event for this
      chatBloc.add(CalendarEventStatusEvent(
        eventId: eventId,
        status: status,
        error: error,
        eventTitle: eventTitle,
        followUpMessage: followUpMessage,
      ));
    } catch (e) {
      debugPrint('CalendarEventService: Error notifying status change: $e');
    }
  }
}
