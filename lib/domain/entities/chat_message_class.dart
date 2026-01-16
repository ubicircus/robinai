class ChatMessage {
  final String id; // Unique id for each message
  final String content; // Message content
  final bool
      isUserMessage; // boolean to know if the message is from the user or not
  final DateTime timestamp; // Time when the message was sent
  final Map<String, dynamic>? uiComponents; // Optional GenUI data

  ChatMessage({
    required this.id,
    required this.content,
    required this.isUserMessage,
    required this.timestamp,
    this.uiComponents,
  });
}
