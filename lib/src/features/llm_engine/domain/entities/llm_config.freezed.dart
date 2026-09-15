// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'llm_config.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

LlmConfig _$LlmConfigFromJson(Map<String, dynamic> json) {
  return _LlmConfig.fromJson(json);
}

/// @nodoc
mixin _$LlmConfig {
  @HiveField(0)
  String get modelPath => throw _privateConstructorUsedError;
  @HiveField(1)
  int get contextSize => throw _privateConstructorUsedError;
  @HiveField(2)
  double get temperature => throw _privateConstructorUsedError;
  @HiveField(3)
  double get topP => throw _privateConstructorUsedError;
  @HiveField(4)
  bool get useMetal => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $LlmConfigCopyWith<LlmConfig> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $LlmConfigCopyWith<$Res> {
  factory $LlmConfigCopyWith(LlmConfig value, $Res Function(LlmConfig) then) =
      _$LlmConfigCopyWithImpl<$Res, LlmConfig>;
  @useResult
  $Res call(
      {@HiveField(0) String modelPath,
      @HiveField(1) int contextSize,
      @HiveField(2) double temperature,
      @HiveField(3) double topP,
      @HiveField(4) bool useMetal});
}

/// @nodoc
class _$LlmConfigCopyWithImpl<$Res, $Val extends LlmConfig>
    implements $LlmConfigCopyWith<$Res> {
  _$LlmConfigCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? modelPath = null,
    Object? contextSize = null,
    Object? temperature = null,
    Object? topP = null,
    Object? useMetal = null,
  }) {
    return _then(_value.copyWith(
      modelPath: null == modelPath
          ? _value.modelPath
          : modelPath // ignore: cast_nullable_to_non_nullable
              as String,
      contextSize: null == contextSize
          ? _value.contextSize
          : contextSize // ignore: cast_nullable_to_non_nullable
              as int,
      temperature: null == temperature
          ? _value.temperature
          : temperature // ignore: cast_nullable_to_non_nullable
              as double,
      topP: null == topP
          ? _value.topP
          : topP // ignore: cast_nullable_to_non_nullable
              as double,
      useMetal: null == useMetal
          ? _value.useMetal
          : useMetal // ignore: cast_nullable_to_non_nullable
              as bool,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$LlmConfigImplCopyWith<$Res>
    implements $LlmConfigCopyWith<$Res> {
  factory _$$LlmConfigImplCopyWith(
          _$LlmConfigImpl value, $Res Function(_$LlmConfigImpl) then) =
      __$$LlmConfigImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {@HiveField(0) String modelPath,
      @HiveField(1) int contextSize,
      @HiveField(2) double temperature,
      @HiveField(3) double topP,
      @HiveField(4) bool useMetal});
}

/// @nodoc
class __$$LlmConfigImplCopyWithImpl<$Res>
    extends _$LlmConfigCopyWithImpl<$Res, _$LlmConfigImpl>
    implements _$$LlmConfigImplCopyWith<$Res> {
  __$$LlmConfigImplCopyWithImpl(
      _$LlmConfigImpl _value, $Res Function(_$LlmConfigImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? modelPath = null,
    Object? contextSize = null,
    Object? temperature = null,
    Object? topP = null,
    Object? useMetal = null,
  }) {
    return _then(_$LlmConfigImpl(
      modelPath: null == modelPath
          ? _value.modelPath
          : modelPath // ignore: cast_nullable_to_non_nullable
              as String,
      contextSize: null == contextSize
          ? _value.contextSize
          : contextSize // ignore: cast_nullable_to_non_nullable
              as int,
      temperature: null == temperature
          ? _value.temperature
          : temperature // ignore: cast_nullable_to_non_nullable
              as double,
      topP: null == topP
          ? _value.topP
          : topP // ignore: cast_nullable_to_non_nullable
              as double,
      useMetal: null == useMetal
          ? _value.useMetal
          : useMetal // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc
@JsonSerializable()
@HiveType(typeId: 3, adapterName: 'LlmConfigAdapter')
class _$LlmConfigImpl implements _LlmConfig {
  const _$LlmConfigImpl(
      {@HiveField(0) required this.modelPath,
      @HiveField(1) this.contextSize = 2048,
      @HiveField(2) this.temperature = 0.1,
      @HiveField(3) this.topP = 0.9,
      @HiveField(4) this.useMetal = true});

  factory _$LlmConfigImpl.fromJson(Map<String, dynamic> json) =>
      _$$LlmConfigImplFromJson(json);

  @override
  @HiveField(0)
  final String modelPath;
  @override
  @JsonKey()
  @HiveField(1)
  final int contextSize;
  @override
  @JsonKey()
  @HiveField(2)
  final double temperature;
  @override
  @JsonKey()
  @HiveField(3)
  final double topP;
  @override
  @JsonKey()
  @HiveField(4)
  final bool useMetal;

  @override
  String toString() {
    return 'LlmConfig(modelPath: $modelPath, contextSize: $contextSize, temperature: $temperature, topP: $topP, useMetal: $useMetal)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$LlmConfigImpl &&
            (identical(other.modelPath, modelPath) ||
                other.modelPath == modelPath) &&
            (identical(other.contextSize, contextSize) ||
                other.contextSize == contextSize) &&
            (identical(other.temperature, temperature) ||
                other.temperature == temperature) &&
            (identical(other.topP, topP) || other.topP == topP) &&
            (identical(other.useMetal, useMetal) ||
                other.useMetal == useMetal));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType, modelPath, contextSize, temperature, topP, useMetal);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$LlmConfigImplCopyWith<_$LlmConfigImpl> get copyWith =>
      __$$LlmConfigImplCopyWithImpl<_$LlmConfigImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$LlmConfigImplToJson(
      this,
    );
  }
}

abstract class _LlmConfig implements LlmConfig {
  const factory _LlmConfig(
      {@HiveField(0) required final String modelPath,
      @HiveField(1) final int contextSize,
      @HiveField(2) final double temperature,
      @HiveField(3) final double topP,
      @HiveField(4) final bool useMetal}) = _$LlmConfigImpl;

  factory _LlmConfig.fromJson(Map<String, dynamic> json) =
      _$LlmConfigImpl.fromJson;

  @override
  @HiveField(0)
  String get modelPath;
  @override
  @HiveField(1)
  int get contextSize;
  @override
  @HiveField(2)
  double get temperature;
  @override
  @HiveField(3)
  double get topP;
  @override
  @HiveField(4)
  bool get useMetal;
  @override
  @JsonKey(ignore: true)
  _$$LlmConfigImplCopyWith<_$LlmConfigImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
