// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat_message_local_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ChatMessageLocalAdapter extends TypeAdapter<ChatMessageLocal> {
  @override
  final int typeId = 1;

  @override
  ChatMessageLocal read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ChatMessageLocal(
      id: fields[0] as String,
      content: fields[1] as String,
      isUserMessage: fields[2] as bool,
      timestamp: fields[3] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, ChatMessageLocal obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.content)
      ..writeByte(2)
      ..write(obj.isUserMessage)
      ..writeByte(3)
      ..write(obj.timestamp);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ChatMessageLocalAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
