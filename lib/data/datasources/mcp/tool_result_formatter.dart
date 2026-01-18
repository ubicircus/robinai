import 'dart:convert';
import 'package:robin_ai/core/service_names.dart';
import 'package:robin_ai/data/datasources/genui/genui_system_prompt.dart';
import 'package:robin_ai/data/datasources/llm_models/ModelFactoryInterface.dart';

class ToolResultFormatter {
  final ModelFactoryInterface _modelFactory;
  final ServiceName _serviceName;
  final String _modelName;
  final String? _userMessage;

  ToolResultFormatter({
    required ModelFactoryInterface modelFactory,
    required ServiceName serviceName,
    required String modelName,
    String? userMessage,
  })  : _modelFactory = modelFactory,
        _serviceName = serviceName,
        _modelName = modelName,
        _userMessage = userMessage;

  /// Format raw tool result using LLM agent
  Future<Map<String, dynamic>> formatResult(
    Map<String, dynamic> rawResult, {
    Map<String, dynamic>? toolCallArguments,
    bool preventToolCalls = false,
  }) async {
    try {
      final routeResult = _tryFormatRouteResult(rawResult, toolCallArguments);
      if (routeResult != null) {
        return routeResult;
      }

      final modelInterface = _modelFactory.getService(_serviceName);

      final formattingPrompt = _buildFormattingPrompt(rawResult, preventToolCalls);

      final response = await modelInterface.sendChatMessageModel(
        modelName: _modelName,
        message: formattingPrompt,
        conversationHistory: [],
        systemPrompt: genUiSystemPrompt,
      );

      // Parse formatted response (but ignore any tool calls if preventToolCalls is true)
      final parsed = _parseFormattedResponse(response);
      
      // Double-check: if preventToolCalls is true, ensure no tool calls slipped through
      if (preventToolCalls && parsed.containsKey('tool_call')) {
        parsed.remove('tool_call');
      }
      
      return parsed;
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

  Map<String, dynamic>? _tryFormatRouteResult(
    Map<String, dynamic> rawResult,
    Map<String, dynamic>? toolCallArguments,
  ) {
    final structured = rawResult['structuredContent'];
    if (structured is! Map<String, dynamic>) return null;

    final distanceText = structured['distance_text']?.toString();
    final durationText = structured['duration_text']?.toString();
    if (distanceText == null || durationText == null) return null;

    // Extract polyline if available
    final polyline = structured['polyline']?.toString();
    
    // Extract origin/destination from tool call arguments or structuredContent
    Map<String, dynamic>? origin;
    Map<String, dynamic>? destination;
    
    // First check tool call arguments (most reliable source)
    if (toolCallArguments != null) {
      if (toolCallArguments.containsKey('origin')) {
        origin = toolCallArguments['origin'] is Map<String, dynamic>
            ? toolCallArguments['origin'] as Map<String, dynamic>
            : null;
      }
      if (toolCallArguments.containsKey('destinations')) {
        final destinations = toolCallArguments['destinations'];
        if (destinations is List && destinations.isNotEmpty) {
          destination = destinations[0] is Map<String, dynamic>
              ? destinations[0] as Map<String, dynamic>
              : null;
        }
      }
    }
    
    // Fallback: check if origin/destination are in structuredContent
    if (origin == null && structured.containsKey('origin')) {
      origin = structured['origin'] is Map<String, dynamic>
          ? structured['origin'] as Map<String, dynamic>
          : null;
    }
    if (destination == null && structured.containsKey('destination')) {
      destination = structured['destination'] is Map<String, dynamic>
          ? structured['destination'] as Map<String, dynamic>
          : null;
    }

    final props = <String, dynamic>{
      'distanceText': distanceText,
      'durationText': durationText,
      'mode': structured['mode']?.toString(),
    };
    
    if (polyline != null && polyline.isNotEmpty) {
      props['polyline'] = polyline;
    }
    
    if (origin != null) {
      props['origin'] = origin;
    }
    
    if (destination != null) {
      props['destination'] = destination;
    }

    return {
      'text': '',
      'ui_components': [
        {
          'type': 'RouteCard',
          'props': props,
        },
      ],
    };
  }

  String _buildFormattingPrompt(Map<String, dynamic> rawResult, bool preventToolCalls) {
    final toolCallWarning = preventToolCalls 
        ? '\n\nCRITICAL: Do NOT include any "tool_call" in your response. You are formatting a tool result, not making a new tool call. Only return "text" and "ui_components".'
        : '';
    
    return '''
Format the following tool execution result using GenUI components. 
The result may be JSON, text, or structured data. Format it in a user-friendly way using appropriate GenUI components.
Keep the response concise and avoid boilerplate like "Here is the summary".
Respond in the same language as this user message:
${_userMessage ?? ''}

Tool Result:
${jsonEncode(rawResult)}

Available GenUI Components:
- InfoCard: For displaying structured information, summaries, or alerts
  Properties: title (string, required), content (string, required), icon (optional: "info", "warning", "check", "error")
- StatusBadge: For showing status indicators
  Properties: label (string, required), status (string, required: "success", "warning", "error", "info")
- RouteCard: For showing route summaries (distance, duration, mode)
  Properties: distanceText (string, required), durationText (string, required), mode (optional: "walk", "drive", "transit", "bicycle"), title (optional), mapsUrl (optional)

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
If the result indicates a status, use StatusBadge.$toolCallWarning
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
