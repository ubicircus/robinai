import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:genui/genui.dart';
import '../../core/service_names.dart';
import '../../domain/entities/chat_message_class.dart' as robin;
import 'llm_models/ModelInterface.dart';

class RealGenUiContentGenerator implements ContentGenerator {
  final ModelInterface model;
  final ServiceName serviceName;
  final String modelName;
  final String systemPrompt;

  final _a2uiMessageController = StreamController<A2uiMessage>.broadcast();
  final _textResponseController = StreamController<String>.broadcast();
  final _errorController = StreamController<ContentGeneratorError>.broadcast();
  final _isProcessing = ValueNotifier<bool>(false);

  RealGenUiContentGenerator({
    required this.model,
    required this.serviceName,
    required this.modelName,
    this.systemPrompt = '',
  });

  @override
  Stream<A2uiMessage> get a2uiMessageStream => _a2uiMessageController.stream;

  @override
  Stream<String> get textResponseStream => _textResponseController.stream;

  @override
  Stream<ContentGeneratorError> get errorStream => _errorController.stream;

  @override
  ValueListenable<bool> get isProcessing => _isProcessing;

  @override
  Future<void> sendRequest(
    ChatMessage message, {
    A2UiClientCapabilities? clientCapabilities,
    Iterable<ChatMessage>? history,
  }) async {
    _isProcessing.value = true;

    try {
      // Map history to robin project's ChatMessage format
      final List<robin.ChatMessage> robinHistory = history?.map((m) {
            if (m is UserMessage) {
              return robin.ChatMessage(
                id: 'user_${DateTime.now().millisecondsSinceEpoch}',
                content: m.text,
                isUserMessage: true,
                timestamp: DateTime.now(),
              );
            } else if (m is AiTextMessage) {
              return robin.ChatMessage(
                id: 'ai_${DateTime.now().millisecondsSinceEpoch}',
                content: m.text,
                isUserMessage: false,
                timestamp: DateTime.now(),
              );
            }
            return robin.ChatMessage(
              id: 'unknown',
              content: '',
              isUserMessage: false,
              timestamp: DateTime.now(),
            );
          }).toList() ??
          [];

      final stream = model.streamChatMessageModel(
        modelName: modelName,
        message: _extractText(message),
        conversationHistory: robinHistory,
        systemPrompt: systemPrompt,
      );

      String buffer = '';

      await for (final chunk in stream) {
        buffer += chunk;
        _textResponseController.add(chunk);
        _processBuffer(buffer);
      }
    } catch (e) {
      _errorController
          .add(ContentGeneratorError(e.toString(), StackTrace.current));
    } finally {
      _isProcessing.value = false;
    }
  }

  String _extractText(ChatMessage message) {
    if (message is UserMessage) return message.text;
    if (message is AiTextMessage) return message.text;
    return '';
  }

  void _processBuffer(String currentContent) {
    // This is a placeholder for a more sophisticated parser
    // For now, we'll look for specific patterns to trigger GenUI updates
    // In a production app, you'd likely use LLM Tool Calling (Function Calling)
    // to get structured A2UI messages directly from the model.

    // Example: If the model output contains a specific trigger for our prototype
    if (currentContent.contains('COMPONENT_TRIGGER:INFO_CARD')) {
      _emitInfoCard();
    }
  }

  void _emitInfoCard() {
    const surfaceId = 'dynamic_surface';
    _a2uiMessageController.add(const SurfaceUpdate(
      surfaceId: surfaceId,
      components: [
        Component(
          id: 'info_live',
          componentProperties: {
            'InfoCard': {
              'title': 'Live from LLM',
              'content': 'This card was triggered by a real LLM stream!',
              'icon': 'check',
            }
          },
        ),
      ],
    ));
    _a2uiMessageController.add(const BeginRendering(
      surfaceId: surfaceId,
      root: 'info_live',
    ));
  }

  @override
  void dispose() {
    _a2uiMessageController.close();
    _textResponseController.close();
    _errorController.close();
    _isProcessing.dispose();
  }
}
