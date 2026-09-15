import '../entities/llm_config.dart';
import '../../../ai_chat/domain/entities/chat_message.dart';
import '../../../ai_chat/domain/entities/persona.dart';

abstract class LlmEngineRepository {
  /// Initializes the local LLM with the given configuration
  Future<void> initialize(LlmConfig config);

  /// Streams the chat response from the LLM
  Stream<String> streamChatResponse({
    required List<ChatMessage> history,
    required Persona persona,
  });

  /// Evaluates the user input and returns a structured JSON (CorrectionResult)
  Future<String> evaluateCorrection({
    required String userText,
    required String systemPrompt,
  });

  /// Disposes of the LLM resources to free memory
  Future<void> dispose();
}
