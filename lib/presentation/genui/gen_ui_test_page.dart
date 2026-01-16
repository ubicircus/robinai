import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:genui/genui.dart';
import '../../core/service_names.dart';
import '../../data/datasources/gen_ui_content_generator.dart';
import '../../data/datasources/genui/genui_system_prompt.dart';
import '../../data/datasources/llm_models/gemini/gemini_model.dart';
import 'catalog.dart';

class GenUiTestPage extends StatefulWidget {
  const GenUiTestPage({super.key});

  @override
  State<GenUiTestPage> createState() => _GenUiTestPageState();
}

class _GenUiTestPageState extends State<GenUiTestPage> {
  late A2uiMessageProcessor _processor;
  late GenUiConversation _conversation;
  bool _useRealLlm = false;
  final _textController =
      TextEditingController(text: 'Show me the prototype widgets');
  final _modelController = TextEditingController(text: 'gemini-1.5-flash');
  List<String> _availableModels = ['gemini-1.5-flash'];
  bool _isLoadingModels = false;

  @override
  void initState() {
    super.initState();
    _initConversation();
    _fetchModels();
  }

  Future<void> _fetchModels() async {
    setState(() => _isLoadingModels = true);
    try {
      final models =
          await GeminiModelImpl().getModels(serviceName: ServiceName.gemini);
      if (mounted) {
        setState(() {
          _availableModels = models;
          if (!_availableModels.contains(_modelController.text)) {
            _modelController.text = _availableModels.isNotEmpty
                ? _availableModels.first
                : 'gemini-1.5-flash';
          }
        });
        // Re-init conversation if we switched to a real model but it wasn't in the list
        if (_useRealLlm) _initConversation();
      }
    } catch (e) {
      debugPrint('Error fetching models: $e');
    } finally {
      if (mounted) setState(() => _isLoadingModels = false);
    }
  }

  void _initConversation() {
    _processor = A2uiMessageProcessor(catalogs: [robinCatalog]);
    final ContentGenerator generator = _useRealLlm
        ? RealGenUiContentGenerator(
            model: GeminiModelImpl(),
            serviceName: ServiceName.gemini,
            modelName: _modelController.text, // Use the controller value
            systemPrompt: genUiSystemPrompt,
          )
        : MockContentGenerator();

    _conversation = GenUiConversation(
      a2uiMessageProcessor: _processor,
      contentGenerator: generator,
    );
  }

  void _toggleGenerator(bool? value) {
    if (value == null) return;
    setState(() {
      _useRealLlm = value;
      _conversation.dispose();
      _initConversation();
    });
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
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: [
                const Text('Use Real LLM (Gemini):'),
                Switch(
                  value: _useRealLlm,
                  onChanged: _toggleGenerator,
                ),
                const SizedBox(width: 8),
                _isLoadingModels
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2))
                    : Expanded(
                        child: DropdownButton<String>(
                          value:
                              _availableModels.contains(_modelController.text)
                                  ? _modelController.text
                                  : _availableModels.first,
                          isExpanded: true,
                          items: _availableModels.map((m) {
                            return DropdownMenuItem(value: m, child: Text(m));
                          }).toList(),
                          onChanged: (val) {
                            if (val != null) {
                              setState(() {
                                _modelController.text = val;
                                _initConversation();
                              });
                            }
                          },
                        ),
                      ),
                IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: _fetchModels,
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _textController,
                    decoration: const InputDecoration(
                      hintText: 'Enter prompt...',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () {
                    _conversation
                        .sendRequest(UserMessage.text(_textController.text));
                  },
                  child: const Text('Send'),
                ),
              ],
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
    final uniqueId = DateTime.now().millisecondsSinceEpoch;
    final surfaceId = 'prototype_surface_$uniqueId';
    debugPrint('Sending A2UI messages for $surfaceId');

    // 1. Cache ALL components FIRST
    _a2uiMessageController.add(SurfaceUpdate(
      surfaceId: surfaceId,
      components: [
        Component(
          id: 'info_$uniqueId',
          componentProperties: {
            'InfoCard': {
              'title': 'Robin AI',
              'content': 'Welcome to the future of AI assistants.',
              'icon': 'info',
            }
          },
        ),
        Component(
          id: 'badge_$uniqueId',
          componentProperties: {
            'StatusBadge': {
              'label': 'Live Status',
              'status': 'success',
            }
          },
        ),
        Component(
          id: 'layout_$uniqueId',
          componentProperties: {
            'Column': {
              'children': ['info_$uniqueId', 'badge_$uniqueId'],
            }
          },
        ),
      ],
    ));

    // 2. Then Begin Rendering with the combined layout as root
    _a2uiMessageController.add(BeginRendering(
      surfaceId: surfaceId,
      root: 'layout_$uniqueId',
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
