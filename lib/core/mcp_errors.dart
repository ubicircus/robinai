class McpError implements Exception {
  final String message;
  final dynamic originalError;

  McpError(this.message, [this.originalError]);

  @override
  String toString() => message;
}

class McpConnectionError extends McpError {
  McpConnectionError(String message, [dynamic originalError])
      : super(message, originalError);
}

class McpProtocolError extends McpError {
  McpProtocolError(String message, [dynamic originalError])
      : super(message, originalError);
}

class McpToolExecutionError extends McpError {
  McpToolExecutionError(String message, [dynamic originalError])
      : super(message, originalError);
}

class McpAuthenticationError extends McpError {
  McpAuthenticationError(String message, [dynamic originalError])
      : super(message, originalError);
}
