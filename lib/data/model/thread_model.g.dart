// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'thread_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ThreadModelAdapter extends TypeAdapter<ThreadModel> {
  @override
  final int typeId = 1;

  @override
  ThreadModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ThreadModel(
      id: fields[0] as String?,
      messages: (fields[1] as List).cast<ChatMessageLocal>(),
      lastMessageTime: fields[2] as DateTime,
      name: fields[3] as String,
    );
  }

  @override
  void write(BinaryWriter writer, ThreadModel obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.messages)
      ..writeByte(2)
      ..write(obj.lastMessageTime)
      ..writeByte(3)
      ..write(obj.name);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ThreadModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
