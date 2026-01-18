/// Abstract transport interface for MCP communication
abstract class McpTransport {
  Future<Map<String, dynamic>> sendRequest(
    String method,
    Map<String, dynamic>? params,
  );

  Future<void> initialize({
    required String protocolVersion,
    Map<String, dynamic>? capabilities,
  });

  void dispose();
}
