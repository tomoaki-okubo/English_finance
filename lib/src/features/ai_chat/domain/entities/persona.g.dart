// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'persona.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PersonaAdapter extends TypeAdapter<_$PersonaImpl> {
  @override
  final int typeId = 2;

  @override
  _$PersonaImpl read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return _$PersonaImpl(
      id: fields[0] as String,
      name: fields[1] as String,
      roleDescription: fields[2] as String,
      systemPrompt: fields[3] as String,
      avatarUrl: fields[4] as String,
    );
  }

  @override
  void write(BinaryWriter writer, _$PersonaImpl obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.roleDescription)
      ..writeByte(3)
      ..write(obj.systemPrompt)
      ..writeByte(4)
      ..write(obj.avatarUrl);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PersonaAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$PersonaImpl _$$PersonaImplFromJson(Map<String, dynamic> json) =>
    _$PersonaImpl(
      id: json['id'] as String,
      name: json['name'] as String,
      roleDescription: json['roleDescription'] as String,
      systemPrompt: json['systemPrompt'] as String,
      avatarUrl: json['avatarUrl'] as String,
    );

Map<String, dynamic> _$$PersonaImplToJson(_$PersonaImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'roleDescription': instance.roleDescription,
      'systemPrompt': instance.systemPrompt,
      'avatarUrl': instance.avatarUrl,
    };
