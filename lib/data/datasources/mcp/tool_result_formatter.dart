import 'dart:convert';
import 'package:robin_ai/core/service_names.dart';
import 'package:robin_ai/data/datasources/genui/genui_system_prompt.dart';
import 'package:robin_ai/data/datasources/llm_models/ModelFactoryInterface.dart';

class ToolResultFormatter {
  final ModelFactoryInterface _modelFactory;
  final ServiceName _serviceName;
  final String _modelName;

  ToolResultFormatter({
    required ModelFactoryInterface modelFactory,
    required ServiceName serviceName,
    required String modelName,
  })  : _modelFactory = modelFactory,
        _serviceName = serviceName,
        _modelName = modelName;

  /// Format raw tool result using LLM agent
  Future<Map<String, dynamic>> formatResult(
    Map<String, dynamic> rawResult,
  ) async {
    try {
      final modelInterface = _modelFactory.getService(_serviceName);

      final formattingPrompt = _buildFormattingPrompt(rawResult);

      final response = await modelInterface.sendChatMessageModel(
        modelName: _modelName,
        message: formattingPrompt,
        conversationHistory: [],
        systemPrompt: genUiSystemPrompt,
      );

      // Parse formatted response
      return _parseFormattedResponse(response);
    } catch (e) {
      // Fallback to raw result
      return {
        'text': 'Tool execution completed. Result: ${jsonEncode(rawResult)}',
        'ui_components': [],
        'raw_result': rawResult,
        'formatting_error': e.toString(),
      };
    }
  }

  String _buildFormattingPrompt(Map<String, dynamic> rawResult) {
    return '''
Format the following tool execution result using GenUI components. 
The result may be JSON, text, or structured data. Format it in a user-friendly way using appropriate GenUI components.

Tool Result:
${jsonEncode(rawResult)}

Available GenUI Components:
- InfoCard: For displaying structured information, summaries, or alerts
  Properties: title (string, required), content (string, required), icon (optional: "info", "warning", "check", "error")
- StatusBadge: For showing status indicators
  Properties: label (string, required), status (string, required: "success", "warning", "error", "info")

Respond in JSON format:
{
  "text": "Brief explanation of the result...",
  "ui_components": [
    {
      "type": "ComponentType",
      "props": { ... }
    }
  ]
}

If the result is simple text, you can just return it in the "text" field without UI components.
If the result is structured data, use InfoCard to display it nicely.
If the result indicates a status, use StatusBadge.
''';
  }

  Map<String, dynamic> _parseFormattedResponse(String response) {
    try {
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
      
      return {
        'text': data['text'] ?? 'Tool execution completed',
        'ui_components': data['ui_components'] ?? [],
      };
    } catch (e) {
      // Fallback
      return {
        'text': response,
        'ui_components': [],
      };
    }
  }
}
