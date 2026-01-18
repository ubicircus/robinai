import 'package:robin_ai/data/datasources/mcp/tool_result_formatter.dart';

class FormatToolResultUseCase {
  final ToolResultFormatter _formatter;

  FormatToolResultUseCase(this._formatter);

  Future<Map<String, dynamic>> call(Map<String, dynamic> rawResult) async {
    return await _formatter.formatResult(rawResult);
  }
}
