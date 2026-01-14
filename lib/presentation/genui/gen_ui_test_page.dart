import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:genui/genui.dart';
import 'catalog.dart';

class GenUiTestPage extends StatefulWidget {
  const GenUiTestPage({super.key});

  @override
  State<GenUiTestPage> createState() => _GenUiTestPageState();
}

class _GenUiTestPageState extends State<GenUiTestPage> {
  late final A2uiMessageProcessor _processor;
  late final GenUiConversation _conversation;

  @override
  void initState() {
    super.initState();
    _processor = A2uiMessageProcessor(catalogs: [robinCatalog]);
    _conversation = GenUiConversation(
      a2uiMessageProcessor: _processor,
      contentGenerator: MockContentGenerator(),
    );
  }

  @override
  void dispose() {
    _conversation.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('GenUI Prototype'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Expanded(
            child: ValueListenableBuilder<List<ChatMessage>>(
              valueListenable: _conversation.conversation,
              builder: (context, conversation, _) {
                return ListView.builder(
                  itemCount: conversation.length,
                  itemBuilder: (context, index) {
                    final message = conversation[index];
                    debugPrint(
                        'Rendering message #$index: ${message.runtimeType}');
                    if (message is UserMessage) {
                      return ListTile(
                        leading: const Icon(Icons.person),
                        title: Text(
                          message.text,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      );
                    } else if (message is AiTextMessage) {
                      return ListTile(
                        leading: const Icon(Icons.smart_toy),
                        title: Text(message.text),
                      );
                    } else if (message is AiUiMessage) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16.0, vertical: 8.0),
                        child: GenUiSurface(
                          host: _conversation.host,
                          surfaceId: message.surfaceId,
                        ),
                      );
                    }
                    return const SizedBox.shrink();
                  },
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton(
              onPressed: () {
                _conversation.sendRequest(
                    UserMessage.text('Show me the prototype widgets'));
              },
              child: const Text('Trigger Mock Response'),
            ),
          ),
        ],
      ),
    );
  }
}

class MockContentGenerator implements ContentGenerator {
  final _a2uiMessageController = StreamController<A2uiMessage>.broadcast();
  final _textResponseController = StreamController<String>.broadcast();
  final _errorController = StreamController<ContentGeneratorError>.broadcast();
  final _processingController = StreamController<bool>.broadcast();
  final _isProcessing = ValueNotifier<bool>(false);

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
    _processingController.add(true);

    await Future.delayed(const Duration(milliseconds: 500));
    _textResponseController.add('Mock: Received request');

    await Future.delayed(const Duration(milliseconds: 500));
    _textResponseController.add('Here are the prototype widgets...');

    await Future.delayed(const Duration(seconds: 1));
    const surfaceId = 'prototype_surface';
    debugPrint('Sending A2UI messages for $surfaceId');

    // 1. Cache ALL components FIRST
    _a2uiMessageController.add(const SurfaceUpdate(
      surfaceId: surfaceId,
      components: [
        Component(
          id: 'info_1',
          componentProperties: {
            'InfoCard': {
              'title': 'Robin AI',
              'content': 'Welcome to the future of AI assistants.',
              'icon': 'info',
            }
          },
        ),
        Component(
          id: 'badge_1',
          componentProperties: {
            'StatusBadge': {
              'label': 'Live Status',
              'status': 'success',
            }
          },
        ),
        Component(
          id: 'layout_1',
          componentProperties: {
            'Column': {
              'children': ['info_1', 'badge_1'],
            }
          },
        ),
      ],
    ));

    // 2. Then Begin Rendering with the combined layout as root
    _a2uiMessageController.add(const BeginRendering(
      surfaceId: surfaceId,
      root: 'layout_1',
    ));
    debugPrint('A2UI messages sent');

    _isProcessing.value = false;
    _processingController.add(false);
  }

  @override
  void dispose() {
    _a2uiMessageController.close();
    _textResponseController.close();
    _errorController.close();
    _processingController.close();
    _isProcessing.dispose();
  }
}
