import 'package:robin_ai/domain/entities/mcp_tool.dart';
import 'package:robin_ai/presentation/config/services/mcp_server_service.dart';

class GetAvailableMcpToolsUseCase {
  final McpServerService _mcpServerService;

  GetAvailableMcpToolsUseCase(this._mcpServerService);

  Future<List<McpTool>> call() async {
    return await _mcpServerService.getAvailableTools();
  }
}
