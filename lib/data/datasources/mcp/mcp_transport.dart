/// Abstract transport interface for MCP communication
abstract class McpTransport {
  Future<Map<String, dynamic>> sendRequest(
    String method,
    Map<String, dynamic>? params,
  );

  /// Initialize the connection and return the server info from the response
  Future<Map<String, dynamic>> initialize({
    required String protocolVersion,
    Map<String, dynamic>? capabilities,
  });

  void dispose();
}
