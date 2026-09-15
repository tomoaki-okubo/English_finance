import 'package:hive_flutter/hive_flutter.dart';
import '../../features/ai_chat/domain/entities/chat_message.dart';
import '../../features/ai_chat/domain/entities/persona.dart';
import '../../features/llm_engine/domain/entities/llm_config.dart';

class HiveSetup {
  static Future<void> init() async {
    await Hive.initFlutter();

    // Register Adapters
    Hive.registerAdapter(MessageSenderAdapter());
    Hive.registerAdapter(ChatMessageAdapter());
    Hive.registerAdapter(PersonaAdapter());
    Hive.registerAdapter(LlmConfigAdapter());

    // Open Boxes
    await Hive.openBox<ChatMessage>('chat_history');
    await Hive.openBox<Persona>('personas');
    await Hive.openBox<LlmConfig>('llm_config');
    await Hive.openBox<String>('saved_drills');
    await Hive.openBox<String>('training_activity');
    await Hive.openBox<String>('notification_settings');
  }

  /// Helper to open/access the notification_settings box
  static Future<Box<String>> openNotificationSettingsBox() async {
    if (Hive.isBoxOpen('notification_settings')) {
      return Hive.box<String>('notification_settings');
    }
    return Hive.openBox<String>('notification_settings');
  }
}
