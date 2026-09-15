import '../../domain/repositories/llm_engine_repository.dart';
import '../../domain/entities/llm_config.dart';
import '../../../ai_chat/domain/entities/chat_message.dart';
import '../../../ai_chat/domain/entities/persona.dart';
import '../drivers/llama_cpp_driver.dart';

class LlmEngineRepositoryImpl implements LlmEngineRepository {
  final LlamaCppDriver _driver;

  LlmEngineRepositoryImpl(this._driver);

  @override
  Future<void> initialize(LlmConfig config) async {
    await _driver.initialize(config);
  }

  @override
  Stream<String> streamChatResponse({
    required List<ChatMessage> history,
    required Persona persona,
  }) {
    final prompt = _buildChatPrompt(history, persona);
    return _driver.generateStream(prompt: prompt);
  }

  @override
  Future<String> evaluateCorrection({
    required String userText,
    required String systemPrompt,
  }) {
    final prompt = '<|im_start|>system\n$systemPrompt<|im_end|>\n<|im_start|>user\n$userText<|im_end|>\n<|im_start|>assistant\n';
    return _driver.generate(prompt: prompt);
  }

  @override
  Future<void> dispose() async {
    await _driver.dispose();
  }

  String _buildChatPrompt(List<ChatMessage> history, Persona persona) {
    final buffer = StringBuffer();
    buffer.writeln('<|im_start|>system');
    buffer.writeln(persona.systemPrompt);
    buffer.writeln('<|im_end|>');

    // Retain only the most recent 4--6 chat messages to fit context budget and maintain focus (lab recommendation)
    final recentHistory = history.length > 6 ? history.sublist(history.length - 6) : history;

    for (final msg in recentHistory) {
      final role = msg.sender == MessageSender.user ? 'user' : 'assistant';
      buffer.writeln('<|im_start|>$role');
      buffer.writeln(msg.content);
      buffer.writeln('<|im_end|>');
    }

    buffer.write('<|im_start|>assistant\n');
    return buffer.toString();
  }
}
