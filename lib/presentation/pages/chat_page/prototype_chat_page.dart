import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:genui/genui.dart';
import 'package:flutter/services.dart';
import 'package:robin_ai/core/service_names.dart';
import 'package:robin_ai/data/datasources/gen_ui_content_generator.dart';
import 'package:robin_ai/data/datasources/genui/genui_system_prompt.dart';
import 'package:robin_ai/data/datasources/llm_models/gemini/gemini_model.dart';
import 'package:robin_ai/presentation/genui/catalog.dart';

class PrototypeChatPage extends StatefulWidget {
  const PrototypeChatPage({super.key});

  @override
  State<PrototypeChatPage> createState() => _PrototypeChatPageState();
}

class _PrototypeChatPageState extends State<PrototypeChatPage> {
  late A2uiMessageProcessor _processor;
  late GenUiConversation _conversation;
  bool _useRealLlm = false;
  final _textController = TextEditingController();
  final _scrollController = ScrollController();

  // Model selection
  final _modelController = TextEditingController(text: 'gemini-1.5-flash');
  List<String> _availableModels = ['gemini-1.5-flash'];
  bool _isLoadingModels = false;
  bool _showModelSelector = false;

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
          if (!_availableModels.contains(_modelController.text) &&
              _availableModels.isNotEmpty) {
            _modelController.text = _availableModels.first;
          }
        });
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
            modelName: _modelController.text,
            systemPrompt: genUiSystemPrompt,
          )
        : _MockContentGenerator();

    _conversation = GenUiConversation(
      a2uiMessageProcessor: _processor,
      contentGenerator: generator,
    );
  }

  void _toggleGenerator(bool useReal) {
    if (_useRealLlm == useReal) return;
    setState(() {
      _useRealLlm = useReal;
      _conversation.dispose();
      _initConversation();
    });
  }

  void _handleSend() {
    if (_textController.text.trim().isEmpty) return;
    final text = _textController.text;
    _textController.clear();
    _conversation.sendRequest(UserMessage.text(text));

    // Scroll to bottom after a short delay to allow list update
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _conversation.dispose();
    _textController.dispose();
    _scrollController.dispose();
    _modelController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Claude-inspired theme colors
    final bgLight = const Color(0xFFFAF9F6); // Warm off-white
    final surfaceColor = Colors.white;
    final userBubbleColor = const Color(0xFFE5E5E0); // Muted warm gray
    final accentColor =
        const Color(0xFFDA7756); // Burnt orange/terracotta accent

    return Scaffold(
      backgroundColor: bgLight,
      appBar: AppBar(
        backgroundColor: bgLight,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new,
              color: Colors.black54, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: InkWell(
          onTap: () => setState(() => _showModelSelector = !_showModelSelector),
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _useRealLlm ? _modelController.text : "Prototype Mode",
                  style: const TextStyle(
                    color: Colors.black87,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    fontFamily: 'Inter', // Fallback to default if not available
                  ),
                ),
                const SizedBox(width: 4),
                Icon(
                  _showModelSelector
                      ? Icons.keyboard_arrow_up
                      : Icons.keyboard_arrow_down,
                  color: Colors.black45,
                  size: 18,
                ),
              ],
            ),
          ),
        ),
        actions: [],
      ),
      body: Stack(
        children: [
          Column(
            children: [
              if (_showModelSelector) _buildModelSelector(),
              Expanded(
                child: ValueListenableBuilder<List<ChatMessage>>(
                  valueListenable: _conversation.conversation,
                  builder: (context, conversation, _) {
                    if (conversation.isEmpty) {
                      return _buildEmptyState(accentColor);
                    }
                    return ListView.separated(
                      controller: _scrollController,
                      padding: const EdgeInsets.all(20),
                      itemCount:
                          conversation.length + 1, // +1 for spacing at bottom
                      separatorBuilder: (c, i) => const SizedBox(height: 24),
                      itemBuilder: (context, index) {
                        if (index == conversation.length)
                          return const SizedBox(height: 80); // Bottom padding

                        final message = conversation[index];
                        return _buildMessageItem(
                            message, surfaceColor, userBubbleColor);
                      },
                    );
                  },
                ),
              ),
              _buildInputArea(surfaceColor, accentColor),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildModelSelector() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text("Mode: ",
                  style: TextStyle(fontWeight: FontWeight.bold)),
              Switch(value: _useRealLlm, onChanged: _toggleGenerator),
              Text(_useRealLlm ? "Real LLM" : "Mock Data"),
            ],
          ),
          if (_useRealLlm)
            Container(
              height: 150,
              margin: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade200),
                borderRadius: BorderRadius.circular(8),
              ),
              child: _isLoadingModels
                  ? const Center(child: CircularProgressIndicator())
                  : ListView.builder(
                      itemCount: _availableModels.length,
                      itemBuilder: (context, index) {
                        final model = _availableModels[index];
                        final isSelected = model == _modelController.text;
                        return ListTile(
                          title: Text(model,
                              style: TextStyle(
                                  fontWeight: isSelected
                                      ? FontWeight.bold
                                      : FontWeight.normal)),
                          trailing: isSelected
                              ? const Icon(Icons.check, size: 16)
                              : null,
                          onTap: () {
                            setState(() {
                              _modelController.text = model;
                              _showModelSelector = false;
                              _initConversation();
                            });
                          },
                        );
                      },
                    ),
            ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(Color accentColor) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 20,
                    offset: const Offset(0, 10)),
              ],
            ),
            child: Icon(Icons.auto_awesome, size: 48, color: accentColor),
          ),
          const SizedBox(height: 24),
          const Text(
            "How can I help you today?",
            style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.black87),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageItem(
      ChatMessage message, Color surfaceColor, Color userBubbleColor) {
    if (message is UserMessage) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 300),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: userBubbleColor,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                message.text,
                style: const TextStyle(
                    fontSize: 16, color: Colors.black87, height: 1.4),
              ),
            ),
          ),
          const SizedBox(width: 12),
          const CircleAvatar(
            backgroundColor: Colors.teal,
            radius: 16,
            child: Icon(Icons.person, size: 20, color: Colors.white),
          ),
        ],
      );
    } else if (message is AiUiMessage) {
      return Padding(
        padding: const EdgeInsets.only(left: 44), // Indent to align with text
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: surfaceColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade200),
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withOpacity(0.03),
                  blurRadius: 10,
                  offset: const Offset(0, 4)),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(12),
                      topRight: Radius.circular(12)),
                  border:
                      Border(bottom: BorderSide(color: Colors.grey.shade100)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.widgets_outlined,
                        size: 16, color: Colors.grey.shade600),
                    const SizedBox(width: 8),
                    Text(
                      "Interactive Component",
                      style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey.shade600),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: GenUiSurface(
                  host: _conversation.host,
                  surfaceId: message.surfaceId,
                ),
              ),
            ],
          ),
        ),
      );
    } else if (message is AiTextMessage) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: const Color(0xFFDA7756), // Orange-ish
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.smart_toy_outlined,
                size: 20, color: Colors.white),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message.text,
              style: const TextStyle(
                  fontSize: 16, color: Colors.black87, height: 1.5),
            ),
          ),
        ],
      );
    }
    return const SizedBox.shrink();
  }

  Widget _buildInputArea(Color surfaceColor, Color accentColor) {
    return Container(
      color: Colors.transparent,
      padding: const EdgeInsets.only(left: 16, right: 16, bottom: 32, top: 10),
      child: Container(
        decoration: BoxDecoration(
          color: surfaceColor,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 20,
                offset: const Offset(0, 5)),
          ],
        ),
        child: Row(
          children: [
            IconButton(
                onPressed: () {},
                icon: const Icon(Icons.add, color: Colors.black45)),
            Expanded(
              child: TextField(
                controller: _textController,
                decoration: const InputDecoration(
                  hintText: "Message...",
                  border: InputBorder.none,
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 8, vertical: 16),
                ),
                onSubmitted: (_) => _handleSend(),
              ),
            ),
            IconButton(
                onPressed: () {},
                icon: const Icon(Icons.mic_none, color: Colors.black45)),
            Container(
              margin: const EdgeInsets.only(right: 8),
              decoration: BoxDecoration(
                color: accentColor,
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: const Icon(Icons.arrow_upward,
                    color: Colors.white, size: 20),
                onPressed: _handleSend,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Internal Mock Generator for quick testing
class _MockContentGenerator implements ContentGenerator {
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

    // Simulate thinking
    await Future.delayed(const Duration(milliseconds: 600));
    _textResponseController.add(
        "I can certainly help with that. Here is an example of the UI components you asked for.");

    await Future.delayed(const Duration(milliseconds: 1000));

    final uniqueId = DateTime.now().millisecondsSinceEpoch;
    final surfaceId = 'prototype_surface_$uniqueId';

    // Send components
    _a2uiMessageController.add(SurfaceUpdate(
      surfaceId: surfaceId,
      components: [
        Component(
          id: 'info_$uniqueId',
          componentProperties: {
            'InfoCard': {
              'title': 'Project Status',
              'content':
                  'The prototype is currently functioning within expected parameters.',
              'icon': 'check',
            }
          },
        ),
        Component(
          id: 'badge_$uniqueId',
          componentProperties: {
            'StatusBadge': {
              'label': 'Operational',
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

    _a2uiMessageController.add(BeginRendering(
      surfaceId: surfaceId,
      root: 'layout_$uniqueId',
    ));

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
