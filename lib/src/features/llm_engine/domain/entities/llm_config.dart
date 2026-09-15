import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hive/hive.dart';

part 'llm_config.freezed.dart';
part 'llm_config.g.dart';

@freezed
class LlmConfig with _$LlmConfig {
  @HiveType(typeId: 3, adapterName: 'LlmConfigAdapter')
  const factory LlmConfig({
    @HiveField(0) required String modelPath,
    @HiveField(1) @Default(2048) int contextSize,
    @HiveField(2) @Default(0.1) double temperature,
    @HiveField(3) @Default(0.9) double topP,
    @HiveField(4) @Default(true) bool useMetal,
  }) = _LlmConfig;

  factory LlmConfig.fromJson(Map<String, dynamic> json) =>
      _$LlmConfigFromJson(json);
}
