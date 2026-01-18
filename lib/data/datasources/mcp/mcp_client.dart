import 'package:robin_ai/core/mcp_errors.dart';
import 'package:robin_ai/data/model/mcp_server_config.dart';
import 'package:robin_ai/domain/entities/mcp_server_info.dart';
import 'package:robin_ai/domain/entities/mcp_tool.dart';
import 'http_mcp_transport.dart';
import 'mcp_transport.dart';

class McpClient {
  final McpServerConfig config;
  McpTransport? _transport;
  bool _initialized = false;
  String _protocolVersion = '2024-11-05'; // MCP protocol version

  McpClient(this.config);

  McpTransport get transport {
    _transport ??= _createTransport();
    return _transport!;
  }

  McpTransport _createTransport() {
    final uri = Uri.parse(config.url);
    
    if (config.transportType == TransportType.http) {
      return HttpMcpTransport(
        baseUrl: uri,
        authToken: config.authType == AuthType.bearerToken
            ? config.authToken
            : null,
      );
    } else {
      throw McpConnectionError('SSE transport not yet implemented');
    }
  }

  /// Initialize connection with MCP server
  Future<McpServerInfo> initialize() async {
    try {
      await transport.initialize(
        protocolVersion: _protocolVersion,
        capabilities: {
          'tools': {},
          'resources': {},
        },
      );

      // Send initialized notification
      await transport.sendRequest('notifications/initialized', null);

      _initialized = true;

      // Get server info
      final result = await transport.sendRequest('initialize', {
        'protocolVersion': _protocolVersion,
        'capabilities': {},
        'clientInfo': {
          'name': 'robin_ai',
          'version': '0.0.2',
        },
      });

      return McpServerInfo(
        name: result['serverInfo']?['name'] ?? 'Unknown',
        version: result['serverInfo']?['version'] ?? '0.0.0',
        capabilities: result['capabilities'] as Map<String, dynamic>?,
        protocolVersion: result['protocolVersion'] ?? _protocolVersion,
      );
    } catch (e) {
      _initialized = false;
      if (e is McpError) rethrow;
      throw McpConnectionError('Failed to initialize: ${e.toString()}', e);
    }
  }

  /// List available tools from the MCP server
  Future<List<McpTool>> listTools() async {
    if (!_initialized) {
      await initialize();
    }

    try {
      final result = await transport.sendRequest('tools/list', null);
      final toolsList = result['tools'] as List<dynamic>? ?? [];

      return toolsList.map((tool) {
        return McpTool(
          name: tool['name'] as String,
          description: tool['description'] as String? ?? '',
          inputSchema: tool['inputSchema'] as Map<String, dynamic>? ?? {},
          serverId: config.id,
        );
      }).toList();
    } catch (e) {
      if (e is McpError) rethrow;
      throw McpProtocolError('Failed to list tools: ${e.toString()}', e);
    }
  }

  /// Call a tool on the MCP server
  Future<Map<String, dynamic>> callTool(
    String toolName,
    Map<String, dynamic> arguments,
  ) async {
    if (!_initialized) {
      await initialize();
    }

    try {
      final result = await transport.sendRequest('tools/call', {
        'name': toolName,
        'arguments': arguments,
      });

      return result;
    } catch (e) {
      if (e is McpError) rethrow;
      throw McpToolExecutionError(
        'Failed to call tool $toolName: ${e.toString()}',
        e,
      );
    }
  }

  /// List available resources
  Future<List<Map<String, dynamic>>> listResources() async {
    if (!_initialized) {
      await initialize();
    }

    try {
      final result = await transport.sendRequest('resources/list', null);
      return (result['resources'] as List<dynamic>? ?? [])
          .map((r) => r as Map<String, dynamic>)
          .toList();
    } catch (e) {
      if (e is McpError) rethrow;
      throw McpProtocolError('Failed to list resources: ${e.toString()}', e);
    }
  }

  /// Read a resource
  Future<Map<String, dynamic>> readResource(String uri) async {
    if (!_initialized) {
      await initialize();
    }

    try {
      final result = await transport.sendRequest('resources/read', {
        'uri': uri,
      });
      return result;
    } catch (e) {
      if (e is McpError) rethrow;
      throw McpProtocolError('Failed to read resource: ${e.toString()}', e);
    }
  }

  /// Test connection to the server
  Future<bool> testConnection() async {
    try {
      await initialize();
      await listTools(); // Try to list tools as a connection test
      return true;
    } catch (e) {
      return false;
    }
  }

  void dispose() {
    _transport?.dispose();
    _transport = null;
    _initialized = false;
  }
}
