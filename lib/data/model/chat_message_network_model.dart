class ChatMessageNetworkModel {
  final String id;
  final String content;
  final DateTime timestamp;
  final Map<String, dynamic>? uiComponents;

  ChatMessageNetworkModel({
    required this.id,
    required this.content,
    required this.timestamp,
    this.uiComponents,
  });
}
