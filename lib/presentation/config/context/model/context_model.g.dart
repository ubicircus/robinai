// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'context_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ContextModelAdapter extends TypeAdapter<ContextModel> {
  @override
  final int typeId = 5;

  @override
  ContextModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ContextModel(
      id: fields[0] as String,
      name: fields[1] as String,
      text: fields[2] as String,
      formatSpecifier: fields[3] as String,
      actionUrl: fields[4] as String,
      isActionActive: fields[5] as bool,
      isContextActive: fields[6] as bool,
      isDefault: fields[7] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, ContextModel obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.text)
      ..writeByte(3)
      ..write(obj.formatSpecifier)
      ..writeByte(4)
      ..write(obj.actionUrl)
      ..writeByte(5)
      ..write(obj.isActionActive)
      ..writeByte(6)
      ..write(obj.isContextActive)
      ..writeByte(7)
      ..write(obj.isDefault);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ContextModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
