import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:robin_ai/core/mcp_errors.dart';
import 'package:robin_ai/data/datasources/mcp/mcp_client.dart';
import 'package:robin_ai/data/model/mcp_server_config.dart';
import 'package:robin_ai/domain/entities/mcp_tool.dart';

class McpServerService {
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  static const _boxName = 'encryptedBox';
  static const _mcpServersKey = 'mcp_servers';
  final Map<String, McpClient> _clients = {};

  Future<Box> _openEncryptedBox() async {
    if (!Hive.isBoxOpen(_boxName)) {
      final encryptionKeyEncoded =
          await _secureStorage.read(key: 'encryptionKey');
      final encryptionKey = encryptionKeyEncoded != null
          ? base64Url.decode(encryptionKeyEncoded)
          : Hive.generateSecureKey();

      if (encryptionKeyEncoded == null) {
        final encryptionKeyEncodedToSave = base64Url.encode(encryptionKey);
        await _secureStorage.write(
            key: 'encryptionKey', value: encryptionKeyEncodedToSave);
      }

      return await Hive.openBox(_boxName,
          encryptionCipher: HiveAesCipher(encryptionKey));
    } else {
      return Hive.box(_boxName);
    }
  }

  /// Save MCP server configuration
  Future<void> saveServerConfig(McpServerConfig config) async {
    final box = await _openEncryptedBox();
    
    // Encrypt auth token if present
    String? encryptedToken;
    if (config.authToken != null && config.authToken!.isNotEmpty) {
      // Store token in secure storage with server ID as key
      await _secureStorage.write(
        key: 'mcp_auth_${config.id}',
        value: config.authToken!,
      );
      encryptedToken = 'encrypted'; // Placeholder
    }

    // Create a copy with encrypted token indicator
    final configToSave = McpServerConfig(
      id: config.id,
      name: config.name,
      url: config.url,
      transportType: config.transportType,
      authType: config.authType,
      authToken: encryptedToken,
      isEnabled: config.isEnabled,
      lastTested: config.lastTested,
      lastError: config.lastError,
    );

    final servers = _getServersList(box);
    final index = servers.indexWhere((s) => s.id == config.id);
    
    if (index >= 0) {
      servers[index] = configToSave;
    } else {
      servers.add(configToSave);
    }

    await box.put(_mcpServersKey, servers.map((s) => s.toJson()).toList());
  }

  /// Get all MCP server configurations
  Future<List<McpServerConfig>> getAllServers() async {
    final box = await _openEncryptedBox();
    final servers = _getServersList(box);

    // Decrypt auth tokens
    for (var server in servers) {
      if (server.authToken == 'encrypted') {
        final token = await _secureStorage.read(key: 'mcp_auth_${server.id}');
        server.authToken = token;
      }
    }

    return servers;
  }

  List<McpServerConfig> _getServersList(Box box) {
    final serversData = box.get(_mcpServersKey);
    if (serversData == null) return [];
    
    // Handle both List<dynamic> and List<Map> cases
    List<dynamic> dataList;
    if (serversData is List) {
      dataList = serversData;
    } else {
      return [];
    }

    return dataList.map((data) {
      // Convert Map<dynamic, dynamic> to Map<String, dynamic>
      Map<String, dynamic> json;
      if (data is Map) {
        json = Map<String, dynamic>.from(data);
      } else {
        return null;
      }
      
      return McpServerConfig(
        id: json['id']?.toString() ?? '',
        name: json['name']?.toString() ?? '',
        url: json['url']?.toString() ?? '',
        transportType: TransportType.values[
          json['transportTypeIndex'] is int 
            ? json['transportTypeIndex'] as int 
            : (json['transportTypeIndex'] as num?)?.toInt() ?? 0
        ],
        authType: AuthType.values[
          json['authTypeIndex'] is int 
            ? json['authTypeIndex'] as int 
            : (json['authTypeIndex'] as num?)?.toInt() ?? 0
        ],
        authToken: json['authToken']?.toString(),
        isEnabled: json['isEnabled'] is bool ? json['isEnabled'] as bool : true,
        lastTested: json['lastTested'] != null
            ? DateTime.tryParse(json['lastTested'].toString())
            : null,
        lastError: json['lastError']?.toString(),
      );
    }).whereType<McpServerConfig>().toList();
  }

  /// Delete a server configuration
  Future<void> deleteServer(String serverId) async {
    final box = await _openEncryptedBox();
    final servers = _getServersList(box);
    servers.removeWhere((s) => s.id == serverId);
    
    await box.put(_mcpServersKey, servers.map((s) => s.toJson()).toList());
    await _secureStorage.delete(key: 'mcp_auth_$serverId');
    
    // Dispose client if exists
    _clients[serverId]?.dispose();
    _clients.remove(serverId);
  }

  /// Test connection to a server
  Future<bool> testConnection(McpServerConfig config) async {
    try {
      final client = McpClient(config);
      final success = await client.testConnection();
      client.dispose();

      // Update last tested timestamp
      config.lastTested = DateTime.now();
      config.lastError = success ? null : 'Connection test failed';
      await saveServerConfig(config);

      return success;
    } catch (e) {
      config.lastTested = DateTime.now();
      config.lastError = e.toString();
      await saveServerConfig(config);
      return false;
    }
  }

  /// Get client for a server (creates if not exists)
  McpClient getClient(McpServerConfig config) {
    if (!_clients.containsKey(config.id)) {
      _clients[config.id] = McpClient(config);
    }
    return _clients[config.id]!;
  }

  /// Get all available tools from enabled servers
  Future<List<McpTool>> getAvailableTools() async {
    final servers = await getAllServers();
    final enabledServers = servers.where((s) => s.isEnabled).toList();
    
    final allTools = <McpTool>[];
    
    for (final server in enabledServers) {
      try {
        final client = getClient(server);
        final tools = await client.listTools();
        allTools.addAll(tools);
      } catch (e) {
        print('Failed to get tools from server ${server.name}: $e');
        // Continue with other servers
      }
    }
    
    return allTools;
  }

  /// Execute a tool call
  Future<Map<String, dynamic>> executeTool(
    String toolName,
    Map<String, dynamic> arguments,
    String? serverId,
  ) async {
    final servers = await getAllServers();
    
    if (serverId != null) {
      final server = servers.firstWhere(
        (s) => s.id == serverId,
        orElse: () => throw McpToolExecutionError('Server not found: $serverId'),
      );
      
      if (!server.isEnabled) {
        throw McpToolExecutionError('Server is disabled: ${server.name}');
      }
      
      final client = getClient(server);
      return await client.callTool(toolName, arguments);
    }
    
    // Try all enabled servers
    for (final server in servers.where((s) => s.isEnabled)) {
      try {
        final client = getClient(server);
        final tools = await client.listTools();
        
        if (tools.any((t) => t.name == toolName)) {
          return await client.callTool(toolName, arguments);
        }
      } catch (e) {
        // Continue to next server
        continue;
      }
    }
    
    throw McpToolExecutionError('Tool not found: $toolName');
  }

  void dispose() {
    for (final client in _clients.values) {
      client.dispose();
    }
    _clients.clear();
  }
}
