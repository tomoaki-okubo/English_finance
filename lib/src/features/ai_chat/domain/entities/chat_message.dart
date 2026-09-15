import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hive/hive.dart';

part 'chat_message.freezed.dart';
part 'chat_message.g.dart';

@HiveType(typeId: 0)
enum MessageSender {
  @HiveField(0)
  user,
  @HiveField(1)
  ai,
  @HiveField(2)
  system,
}

@freezed
class ChatMessage with _$ChatMessage {
  @HiveType(typeId: 1, adapterName: 'ChatMessageAdapter')
  const factory ChatMessage({
    @HiveField(0) required String id,
    @HiveField(1) required MessageSender sender,
    @HiveField(2) required String content,
    @HiveField(3) required DateTime timestamp,
    // TODO: Add CorrectionResult when defined
    // @HiveField(4) CorrectionResult? correction,
  }) = _ChatMessage;

  factory ChatMessage.user({required String content}) => ChatMessage(
        id: DateTime.now().toIso8601String(), // Temporary ID generation
        sender: MessageSender.user,
        content: content,
        timestamp: DateTime.now(),
      );

  factory ChatMessage.ai({required String content}) => ChatMessage(
        id: DateTime.now().toIso8601String(),
        sender: MessageSender.ai,
        content: content,
        timestamp: DateTime.now(),
      );

  factory ChatMessage.fromJson(Map<String, dynamic> json) =>
      _$ChatMessageFromJson(json);
}
