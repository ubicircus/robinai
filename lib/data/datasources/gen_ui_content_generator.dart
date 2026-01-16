import 'dart:async';
import 'dart:convert';
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
        // logic moved to post-stream processing to handle JSON
      }

      _processJsonBuffer(buffer);
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

  void _processJsonBuffer(String buffer) {
    try {
      // Clean up markdown code blocks if present
      String jsonStr = buffer.trim();
      if (jsonStr.startsWith('```json')) {
        jsonStr = jsonStr.substring(7);
      }
      if (jsonStr.startsWith('```')) {
        jsonStr = jsonStr.substring(3);
      }
      if (jsonStr.endsWith('```')) {
        jsonStr = jsonStr.substring(0, jsonStr.length - 3);
      }

      final data = json.decode(jsonStr);

      // 1. Emit Text
      if (data['text'] != null) {
        _textResponseController.add(data['text']);
      }

      // 2. Emit UI Components
      if (data['ui_components'] != null) {
        final List components = data['ui_components'];
        if (components.isNotEmpty) {
          _emitComponents(components);
        }
      }
    } catch (e) {
      // Fallback: If JSON parsing fails, just emit the raw buffer as text
      // This handles cases where the model refuses to output JSON
      _textResponseController.add(buffer);
      debugPrint('GenUI JSON parsing error: $e');
    }
  }

  void _emitComponents(List componentsData) {
    final uniqueId = DateTime.now().millisecondsSinceEpoch;
    final surfaceId = 'dynamic_surface_$uniqueId';
    debugPrint('Generating GenUI with SurfaceID: $surfaceId');
    final List<Component> components = [];
    final List<String> componentIds = [];

    for (var i = 0; i < componentsData.length; i++) {
      final comp = componentsData[i];
      final type = comp['type'];
      final props = comp['props'];
      final id = 'comp_${uniqueId}_$i';

      if (type != null && props != null) {
        components.add(Component(
          id: id,
          componentProperties: {
            type: props,
          },
        ));
        componentIds.add(id);
      }
    }

    // Add a Column layout to hold them
    components.add(Component(id: 'layout_root_$uniqueId', componentProperties: {
      'Column': {
        'children': componentIds,
      }
    }));

    _a2uiMessageController.add(SurfaceUpdate(
      surfaceId: surfaceId,
      components: components,
    ));

    _a2uiMessageController.add(BeginRendering(
      surfaceId: surfaceId,
      root: 'layout_root_$uniqueId',
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
