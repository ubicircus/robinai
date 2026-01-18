import 'package:robin_ai/domain/entities/mcp_tool.dart';
import 'package:intl/intl.dart';

class GenUiSystemPromptBuilder {
  static String buildSystemPrompt({
    required String basePrompt,
    List<McpTool>? mcpTools,
  }) {
    // Add current time and timezone information at the beginning
    final timeInfo = _getCurrentTimeInfo();
    String prompt = timeInfo + '\n\n' + basePrompt;

    if (mcpTools != null && mcpTools.isNotEmpty) {
      prompt += '\n\n';
      prompt += 'MCP TOOLS AVAILABLE:\n';
      prompt += 'You have access to the following MCP (Model Context Protocol) tools:\n\n';

      for (final tool in mcpTools) {
        prompt += 'Tool: ${tool.name}\n';
        prompt += 'Description: ${tool.description}\n';
        
        if (tool.inputSchema.isNotEmpty) {
          prompt += 'Input Schema:\n';
          prompt += _formatSchema(tool.inputSchema, indent: 2);
        }
        
        prompt += '\n';
      }

      prompt += 'TOOL CALLING FORMAT:\n';
      prompt += 'To call a tool, include a JSON object in your response with this structure:\n';
      prompt += '{\n';
      prompt += '  "text": "Your response text...",\n';
      prompt += '  "tool_call": {\n';
      prompt += '    "tool": "toolName",\n';
      prompt += '    "arguments": { ... }\n';
      prompt += '  },\n';
      prompt += '  "ui_components": [ ... ]\n';
      prompt += '}\n\n';
      prompt += 'IMPORTANT: If you decide to use a tool, include the tool_call in your JSON response. ';
      prompt += 'The tool will be executed and the result will be formatted for display.\n';
    }

    return prompt;
  }

  static String _formatSchema(
    Map<String, dynamic> schema, {
    int indent = 0,
  }) {
    // Simple schema formatting - can be enhanced
    final indentStr = ' ' * indent;
    String result = '';
    
    if (schema.containsKey('type')) {
      result += '${indentStr}Type: ${schema['type']}\n';
    }
    
    if (schema.containsKey('properties')) {
      result += '${indentStr}Properties:\n';
      final properties = schema['properties'] as Map<String, dynamic>;
      for (final entry in properties.entries) {
        final propValue = entry.value;
        if (propValue is Map<String, dynamic>) {
          result += '${indentStr}  - ${entry.key}: ${propValue['type'] ?? 'object'}\n';
        } else {
          result += '${indentStr}  - ${entry.key}: $propValue\n';
        }
      }
    }
    
    if (schema.containsKey('required')) {
      final required = schema['required'] as List<dynamic>;
      if (required.isNotEmpty) {
        result += '${indentStr}Required: ${required.join(", ")}\n';
      }
    }
    
    return result;
  }

  /// Gets current time information formatted for the LLM
  static String _getCurrentTimeInfo() {
    final now = DateTime.now();
    final dateFormat = DateFormat('EEEE, MMMM d, yyyy');
    final timeFormat = DateFormat('h:mm:ss a');
    final isoFormat = DateFormat('yyyy-MM-ddTHH:mm:ss');
    
    final dateStr = dateFormat.format(now);
    final timeStr = timeFormat.format(now);
    final isoStr = isoFormat.format(now);
    final timezoneName = now.timeZoneName;
    final timezoneOffset = now.timeZoneOffset;
    
    // Format offset as +/-HH:MM
    final offsetHours = timezoneOffset.inHours;
    final offsetMinutes = (timezoneOffset.inMinutes % 60).abs();
    final offsetStr = '${offsetHours >= 0 ? '+' : ''}${offsetHours.toString().padLeft(2, '0')}:${offsetMinutes.toString().padLeft(2, '0')}';
    
    return '''CURRENT TIME AND DATE:
- Current Date: $dateStr
- Current Time: $timeStr
- ISO 8601 Format: ${isoStr}${offsetStr}
- Timezone: $timezoneName (UTC$offsetStr)
- Day of Week: ${DateFormat('EEEE').format(now)}
- Day of Year: ${now.difference(DateTime(now.year, 1, 1)).inDays + 1}

You should always be aware of the current time and date when responding to user queries. When scheduling events or discussing time-sensitive matters, use the current time as reference.''';
  }
}
