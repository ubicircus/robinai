import 'package:hive/hive.dart';

part 'mcp_server_config.g.dart';

enum TransportType {
  http,
  sse,
}

enum AuthType {
  none,
  bearerToken,
  oauth,
}

@HiveType(typeId: 6)
class McpServerConfig extends HiveObject {
  @HiveField(0)
  late String id;

  @HiveField(1)
  late String name;

  @HiveField(2)
  late String url;

  @HiveField(3)
  late int transportTypeIndex; // Index for TransportType enum

  @HiveField(4)
  late int authTypeIndex; // Index for AuthType enum

  @HiveField(5)
  String? authToken; // Encrypted token

  @HiveField(6)
  late bool isEnabled;

  @HiveField(7)
  DateTime? lastTested;

  @HiveField(8)
  String? lastError;

  TransportType get transportType => TransportType.values[transportTypeIndex];
  set transportType(TransportType value) => transportTypeIndex = value.index;

  AuthType get authType => AuthType.values[authTypeIndex];
  set authType(AuthType value) => authTypeIndex = value.index;

  McpServerConfig({
    required this.id,
    required this.name,
    required this.url,
    TransportType? transportType,
    AuthType? authType,
    this.authToken,
    this.isEnabled = true,
    this.lastTested,
    this.lastError,
  })  : transportTypeIndex = (transportType ?? TransportType.http).index,
        authTypeIndex = (authType ?? AuthType.none).index;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'url': url,
      'transportTypeIndex': transportTypeIndex,
      'authTypeIndex': authTypeIndex,
      'authToken': authToken,
      'isEnabled': isEnabled,
      'lastTested': lastTested?.toIso8601String(),
      'lastError': lastError,
    };
  }
}
