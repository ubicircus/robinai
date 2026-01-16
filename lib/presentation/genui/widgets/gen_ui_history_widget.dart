import 'package:flutter/material.dart';
import 'package:genui/genui.dart';
import 'package:robin_ai/presentation/genui/catalog.dart';
import '../history_content_generator.dart';

class GenUiHistoryWidget extends StatefulWidget {
  final Map<String, dynamic> uiComponents;

  const GenUiHistoryWidget({super.key, required this.uiComponents});

  @override
  State<GenUiHistoryWidget> createState() => _GenUiHistoryWidgetState();
}

class _GenUiHistoryWidgetState extends State<GenUiHistoryWidget> {
  late A2uiMessageProcessor _processor;
  late GenUiConversation _conversation;
  late HistoryContentGenerator _generator;

  // We need to capture the surface ID which will be emitted/generated
  // Since our generator generates a random ID, we need to listen for it/know it.
  // Ideally, the generator should tell us, or we pass it in.
  // For simplicity, we can listen to the stream locally or just let the surface update itself?
  // Use a StreamBuilder or ValueListenable?
  // GenUiConversation exposes conversation list. We can look for AiUiMessage.

  String? _surfaceId;

  @override
  void initState() {
    super.initState();
    _initGenUi();
  }

  void _initGenUi() {
    // If the map has 'ui_components' wrapper, use it effectively.
    // The Generator expects the map that contains 'ui_components'.

    _processor = A2uiMessageProcessor(catalogs: [robinCatalog]);
    _generator = HistoryContentGenerator(widget.uiComponents);

    _conversation = GenUiConversation(
      a2uiMessageProcessor: _processor,
      contentGenerator: _generator,
    );

    // Listen for the surface ID
    _conversation.conversation.addListener(_checkForSurfaceId);
  }

  void _checkForSurfaceId() {
    final messages = _conversation.conversation.value;
    for (final msg in messages) {
      if (msg is AiUiMessage) {
        if (_surfaceId != msg.surfaceId) {
          setState(() {
            _surfaceId = msg.surfaceId;
          });
        }
        break; // Assuming one surface per message for now
      }
    }
  }

  @override
  void dispose() {
    _conversation.conversation.removeListener(_checkForSurfaceId);
    _conversation.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_surfaceId == null) {
      return const SizedBox.shrink(); // Waiting for hydration
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: GenUiSurface(
        host: _conversation.host,
        surfaceId: _surfaceId!,
      ),
    );
  }
}
