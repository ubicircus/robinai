class GroqChatMessageModel {
  final GroqChatMessageRole role;
  final GroqChatMessageContentItemModel content;

  GroqChatMessageModel({
    required this.role,
    required this.content,
  });
}

enum GroqChatMessageRole {
  system,
  user,
  assistant;
}

extension GroqChatMessageRoleExtension on GroqChatMessageRole {
  String get value {
    switch (this) {
      case GroqChatMessageRole.system:
        return 'system';
      case GroqChatMessageRole.user:
        return 'user';
      case GroqChatMessageRole.assistant:
        return 'assistant';
      default:
        throw Exception('Unsupported role');
    }
  }
}

class GroqChatMessageContentItemModel {
  final String text;

  GroqChatMessageContentItemModel({
    required this.text,
  });

  factory GroqChatMessageContentItemModel.text(String text) {
    return GroqChatMessageContentItemModel(text: text);
  }
}
