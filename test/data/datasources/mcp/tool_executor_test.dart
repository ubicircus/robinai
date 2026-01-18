import 'package:flutter_test/flutter_test.dart';
import 'package:robin_ai/core/mcp_errors.dart';
import 'package:robin_ai/data/datasources/mcp/mcp_tool_executor.dart';
import 'package:robin_ai/presentation/config/services/mcp_server_service.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';

@GenerateMocks([McpServerService])
void main() {
  group('McpToolExecutor', () {
    test('should parse tool call from JSON response', () {
      final service = MockMcpServerService();
      final executor = McpToolExecutor(service);

      final response = '''
      {
        "text": "I'll call the tool",
        "tool_call": {
          "tool": "get_weather",
          "arguments": {"city": "New York"}
        }
      }
      ''';

      final toolCall = executor.parseToolCall(response);
      expect(toolCall, isNotNull);
      expect(toolCall!['tool'], 'get_weather');
      expect(toolCall['arguments']['city'], 'New York');
    });

    test('should return null for response without tool call', () {
      final service = MockMcpServerService();
      final executor = McpToolExecutor(service);

      final response = '{"text": "Just a regular response"}';
      final toolCall = executor.parseToolCall(response);
      expect(toolCall, isNull);
    });

    test('should parse tool call from markdown code block', () {
      final service = MockMcpServerService();
      final executor = McpToolExecutor(service);

      final response = '''
      ```json
      {
        "tool_call": {
          "tool": "test_tool",
          "arguments": {}
        }
      }
      ```
      ''';

      final toolCall = executor.parseToolCall(response);
      expect(toolCall, isNotNull);
      expect(toolCall!['tool'], 'test_tool');
    });
  });
}
