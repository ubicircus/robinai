class McpTool {
  final String name;
  final String description;
  final Map<String, dynamic> inputSchema;
  final String? serverId; // ID of the MCP server that provides this tool

  McpTool({
    required this.name,
    required this.description,
    required this.inputSchema,
    this.serverId,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
      'inputSchema': inputSchema,
      'serverId': serverId,
    };
  }

  factory McpTool.fromJson(Map<String, dynamic> json) {
    return McpTool(
      name: json['name'] as String,
      description: json['description'] as String,
      inputSchema: json['inputSchema'] as Map<String, dynamic>,
      serverId: json['serverId'] as String?,
    );
  }
}
