import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:robin_ai/core/mcp_errors.dart';
import 'mcp_transport.dart';

class HttpMcpTransport implements McpTransport {
  final Uri baseUrl;
  final String? authToken;
  final Duration timeout;

  HttpMcpTransport({
    required this.baseUrl,
    this.authToken,
    this.timeout = const Duration(seconds: 30),
  });

  @override
  Future<Map<String, dynamic>> sendRequest(
    String method,
    Map<String, dynamic>? params,
  ) async {
    try {
      final headers = <String, String>{
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };

      if (authToken != null && authToken!.isNotEmpty) {
        headers['Authorization'] = 'Bearer $authToken';
      }

      final requestBody = jsonEncode({
        'jsonrpc': '2.0',
        'id': DateTime.now().millisecondsSinceEpoch.toString(),
        'method': method,
        if (params != null) 'params': params,
      });

      final response = await http
          .post(
            baseUrl,
            headers: headers,
            body: requestBody,
          )
          .timeout(timeout);

      if (response.statusCode == 401 || response.statusCode == 403) {
        throw McpAuthenticationError(
          'Authentication failed: ${response.statusCode}',
        );
      }

      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw McpConnectionError(
          'HTTP error ${response.statusCode}: ${response.body}',
        );
      }

      final responseData = jsonDecode(response.body) as Map<String, dynamic>;

      if (responseData.containsKey('error')) {
        final error = responseData['error'] as Map<String, dynamic>;
        throw McpProtocolError(
          'MCP error: ${error['message'] ?? 'Unknown error'}',
          error,
        );
      }

      return responseData['result'] as Map<String, dynamic>? ?? {};
    } on http.ClientException catch (e) {
      throw McpConnectionError('Network error: ${e.message}', e);
    } on FormatException catch (e) {
      throw McpProtocolError('Invalid JSON response: ${e.message}', e);
    } catch (e) {
      if (e is McpError) rethrow;
      throw McpConnectionError('Unexpected error: ${e.toString()}', e);
    }
  }

  @override
  Future<void> initialize({
    required String protocolVersion,
    Map<String, dynamic>? capabilities,
  }) async {
    await sendRequest('initialize', {
      'protocolVersion': protocolVersion,
      'capabilities': capabilities ?? {},
      'clientInfo': {
        'name': 'robin_ai',
        'version': '0.0.2',
      },
    });
  }

  @override
  void dispose() {
    // HTTP transport doesn't need cleanup
  }
}
