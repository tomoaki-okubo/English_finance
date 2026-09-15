// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat_message.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class MessageSenderAdapter extends TypeAdapter<MessageSender> {
  @override
  final int typeId = 0;

  @override
  MessageSender read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return MessageSender.user;
      case 1:
        return MessageSender.ai;
      case 2:
        return MessageSender.system;
      default:
        return MessageSender.user;
    }
  }

  @override
  void write(BinaryWriter writer, MessageSender obj) {
    switch (obj) {
      case MessageSender.user:
        writer.writeByte(0);
        break;
      case MessageSender.ai:
        writer.writeByte(1);
        break;
      case MessageSender.system:
        writer.writeByte(2);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MessageSenderAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class ChatMessageAdapter extends TypeAdapter<_$ChatMessageImpl> {
  @override
  final int typeId = 1;

  @override
  _$ChatMessageImpl read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return _$ChatMessageImpl(
      id: fields[0] as String,
      sender: fields[1] as MessageSender,
      content: fields[2] as String,
      timestamp: fields[3] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, _$ChatMessageImpl obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.sender)
      ..writeByte(2)
      ..write(obj.content)
      ..writeByte(3)
      ..write(obj.timestamp);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ChatMessageAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ChatMessageImpl _$$ChatMessageImplFromJson(Map<String, dynamic> json) =>
    _$ChatMessageImpl(
      id: json['id'] as String,
      sender: $enumDecode(_$MessageSenderEnumMap, json['sender']),
      content: json['content'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
    );

Map<String, dynamic> _$$ChatMessageImplToJson(_$ChatMessageImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'sender': _$MessageSenderEnumMap[instance.sender]!,
      'content': instance.content,
      'timestamp': instance.timestamp.toIso8601String(),
    };

const _$MessageSenderEnumMap = {
  MessageSender.user: 'user',
  MessageSender.ai: 'ai',
  MessageSender.system: 'system',
};
