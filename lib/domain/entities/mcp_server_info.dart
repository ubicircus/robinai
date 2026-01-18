class McpServerInfo {
  final String name;
  final String version;
  final Map<String, dynamic>? capabilities;
  final String protocolVersion;

  McpServerInfo({
    required this.name,
    required this.version,
    this.capabilities,
    required this.protocolVersion,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'version': version,
      'capabilities': capabilities,
      'protocolVersion': protocolVersion,
    };
  }

  factory McpServerInfo.fromJson(Map<String, dynamic> json) {
    return McpServerInfo(
      name: json['name'] as String,
      version: json['version'] as String,
      capabilities: json['capabilities'] as Map<String, dynamic>?,
      protocolVersion: json['protocolVersion'] as String,
    );
  }
}
