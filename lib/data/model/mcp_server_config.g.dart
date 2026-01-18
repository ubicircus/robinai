// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'mcp_server_config.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class McpServerConfigAdapter extends TypeAdapter<McpServerConfig> {
  @override
  final int typeId = 6;

  @override
  McpServerConfig read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return McpServerConfig(
      id: fields[0] as String,
      name: fields[1] as String,
      url: fields[2] as String,
      authToken: fields[5] as String?,
      isEnabled: fields[6] as bool,
      lastTested: fields[7] as DateTime?,
      lastError: fields[8] as String?,
    )
      ..transportTypeIndex = fields[3] as int
      ..authTypeIndex = fields[4] as int;
  }

  @override
  void write(BinaryWriter writer, McpServerConfig obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.url)
      ..writeByte(3)
      ..write(obj.transportTypeIndex)
      ..writeByte(4)
      ..write(obj.authTypeIndex)
      ..writeByte(5)
      ..write(obj.authToken)
      ..writeByte(6)
      ..write(obj.isEnabled)
      ..writeByte(7)
      ..write(obj.lastTested)
      ..writeByte(8)
      ..write(obj.lastError);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is McpServerConfigAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
