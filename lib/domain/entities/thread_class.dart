class Thread {
  final String id; // Unique identifier for the thread
  final List<String> participantIds; // List of participant user IDs
  final String lastMessage; // Preview or content of the last message sent
  final DateTime lastMessageTime; // Timestamp of the last message

  Thread({
    required this.id,
    required this.participantIds,
    required this.lastMessage,
    required this.lastMessageTime,
  });
}
