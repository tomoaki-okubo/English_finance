// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'llm_config.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class LlmConfigAdapter extends TypeAdapter<_$LlmConfigImpl> {
  @override
  final int typeId = 3;

  @override
  _$LlmConfigImpl read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return _$LlmConfigImpl(
      modelPath: fields[0] as String,
      contextSize: fields[1] as int,
      temperature: fields[2] as double,
      topP: fields[3] as double,
      useMetal: fields[4] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, _$LlmConfigImpl obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.modelPath)
      ..writeByte(1)
      ..write(obj.contextSize)
      ..writeByte(2)
      ..write(obj.temperature)
      ..writeByte(3)
      ..write(obj.topP)
      ..writeByte(4)
      ..write(obj.useMetal);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LlmConfigAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$LlmConfigImpl _$$LlmConfigImplFromJson(Map<String, dynamic> json) =>
    _$LlmConfigImpl(
      modelPath: json['modelPath'] as String,
      contextSize: (json['contextSize'] as num?)?.toInt() ?? 2048,
      temperature: (json['temperature'] as num?)?.toDouble() ?? 0.1,
      topP: (json['topP'] as num?)?.toDouble() ?? 0.9,
      useMetal: json['useMetal'] as bool? ?? true,
    );

Map<String, dynamic> _$$LlmConfigImplToJson(_$LlmConfigImpl instance) =>
    <String, dynamic>{
      'modelPath': instance.modelPath,
      'contextSize': instance.contextSize,
      'temperature': instance.temperature,
      'topP': instance.topP,
      'useMetal': instance.useMetal,
    };
