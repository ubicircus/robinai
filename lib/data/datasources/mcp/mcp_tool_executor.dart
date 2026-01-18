import 'dart:convert';
import 'package:robin_ai/core/mcp_errors.dart';
import 'package:robin_ai/presentation/config/services/mcp_server_service.dart';

class McpToolExecutor {
  final McpServerService _mcpServerService;

  McpToolExecutor(this._mcpServerService);

  /// Parse tool call from LLM response
  Map<String, dynamic>? parseToolCall(String response) {
    try {
      // Try to extract JSON from response
      String jsonStr = response.trim();
      
      // Remove markdown code blocks if present
      final codeBlockRegex = RegExp(r'```json\s*(\{[\s\S]*?\})\s*```', caseSensitive: false);
      final match = codeBlockRegex.firstMatch(response);
      if (match != null) {
        jsonStr = match.group(1) ?? jsonStr;
      } else {
        // Try to find JSON object
        final start = response.indexOf('{');
        final end = response.lastIndexOf('}');
        if (start != -1 && end != -1 && end > start) {
          jsonStr = response.substring(start, end + 1);
        }
      }

      final data = json.decode(jsonStr) as Map<String, dynamic>;
      
      if (data.containsKey('tool_call')) {
        return data['tool_call'] as Map<String, dynamic>;
      }
      
      return null;
    } catch (e) {
      // Not a valid tool call
      return null;
    }
  }

  /// Execute a tool call
  Future<Map<String, dynamic>> executeToolCall(
    Map<String, dynamic> toolCall,
  ) async {
    final toolName = toolCall['tool'] as String?;
    final arguments = toolCall['arguments'] as Map<String, dynamic>?;
    final serverId = toolCall['serverId'] as String?;

    if (toolName == null) {
      throw McpToolExecutionError('Tool name is required');
    }

    if (arguments == null) {
      throw McpToolExecutionError('Tool arguments are required');
    }

    return await _mcpServerService.executeTool(
      toolName,
      arguments,
      serverId,
    );
  }
}
