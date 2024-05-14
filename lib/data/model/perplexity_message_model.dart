class PerplexityChatMessageModel {
  final PerplexityChatMessageRole role;
  final PerplexityChatMessageContentItemModel content;

  PerplexityChatMessageModel({
    required this.role,
    required this.content,
  });
}

enum PerplexityChatMessageRole { system, user, assistant }

extension PerplexityChatMessageRoleExtension on PerplexityChatMessageRole {
  String get value {
    switch (this) {
      case PerplexityChatMessageRole.system:
        return 'system';
      case PerplexityChatMessageRole.user:
        return 'user';
      case PerplexityChatMessageRole.assistant:
        return 'assistant';
      default:
        throw Exception('Unsupported role');
    }
  }
}

class PerplexityChatMessageContentItemModel {
  final String text;

  PerplexityChatMessageContentItemModel({
    required this.text,
  });

  factory PerplexityChatMessageContentItemModel.text(String text) {
    return PerplexityChatMessageContentItemModel(text: text);
  }
}
