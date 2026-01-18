import 'package:flutter_test/flutter_test.dart';
import 'package:robin_ai/core/mcp_errors.dart';
import 'package:robin_ai/data/datasources/mcp/mcp_client.dart';
import 'package:robin_ai/data/model/mcp_server_config.dart';

void main() {
  group('McpClient', () {
    test('should create client with HTTP transport', () {
      final config = McpServerConfig(
        id: 'test-id',
        name: 'Test Server',
        url: 'https://example.com/mcp',
        transportType: TransportType.http,
      );

      final client = McpClient(config);
      expect(client, isNotNull);
    });

    test('should throw error for unsupported transport', () {
      final config = McpServerConfig(
        id: 'test-id',
        name: 'Test Server',
        url: 'https://example.com/mcp',
        transportType: TransportType.sse,
      );

      final client = McpClient(config);
      expect(
        () => client.transport,
        throwsA(isA<McpConnectionError>()),
      );
    });

    test('should handle bearer token auth', () {
      final config = McpServerConfig(
        id: 'test-id',
        name: 'Test Server',
        url: 'https://example.com/mcp',
        transportType: TransportType.http,
        authType: AuthType.bearerToken,
        authToken: 'test-token',
      );

      final client = McpClient(config);
      expect(client, isNotNull);
      expect(config.authToken, 'test-token');
    });
  });
}
