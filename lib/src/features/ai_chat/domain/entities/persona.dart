import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hive/hive.dart';

part 'persona.freezed.dart';
part 'persona.g.dart';

@freezed
class Persona with _$Persona {
  @HiveType(typeId: 2, adapterName: 'PersonaAdapter')
  const factory Persona({
    @HiveField(0) required String id,
    @HiveField(1) required String name,
    @HiveField(2) required String roleDescription,
    @HiveField(3) required String systemPrompt,
    @HiveField(4) required String avatarUrl,
  }) = _Persona;

  factory Persona.fromJson(Map<String, dynamic> json) =>
      _$PersonaFromJson(json);
}
