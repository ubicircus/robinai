import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:genui/genui.dart';

class HistoryContentGenerator implements ContentGenerator {
  final Map<String, dynamic> _componentsData;
  final _a2uiMessageController = StreamController<A2uiMessage>.broadcast();
  final _textResponseController = StreamController<String>.broadcast();
  final _errorController = StreamController<ContentGeneratorError>.broadcast();
  final _isProcessing = ValueNotifier<bool>(false);

  HistoryContentGenerator(this._componentsData) {
    // Emit content immediately after listeners have a chance to subscribe
    Future.microtask(_emitFromHistory);
  }

  void _emitFromHistory() {
    try {
      if (_componentsData['ui_components'] == null) return;

      final componentsList = _componentsData['ui_components'] as List;
      _emitComponents(componentsList);
    } catch (e) {
      debugPrint('Error emitting history genui: $e');
    }
  }

  void _emitComponents(List componentsData) {
    // Use a fixed/stored ID or generate one. Ideally we should have stored the surfaceID too.
    // For now, generate a new one, as long as it's consistent for this instance.
    final uniqueId = DateTime.now().millisecondsSinceEpoch;
    final surfaceId = 'history_surface_$uniqueId';

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
    // History generator does not support sending new requests
  }

  @override
  void dispose() {
    _a2uiMessageController.close();
    _textResponseController.close();
    _errorController.close();
    _isProcessing.dispose();
  }
}
