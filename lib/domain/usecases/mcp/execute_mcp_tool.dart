import 'package:robin_ai/data/datasources/mcp/mcp_tool_executor.dart';

class ExecuteMcpToolUseCase {
  final McpToolExecutor _toolExecutor;

  ExecuteMcpToolUseCase(this._toolExecutor);

  Future<Map<String, dynamic>> call(Map<String, dynamic> toolCall) async {
    return await _toolExecutor.executeToolCall(toolCall);
  }
}
