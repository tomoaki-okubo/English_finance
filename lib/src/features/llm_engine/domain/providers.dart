import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/drivers/llama_cpp_driver.dart';
import '../data/repositories/llm_engine_repository_impl.dart';
import 'repositories/llm_engine_repository.dart';

// Driver Provider
final llamaCppDriverProvider = Provider<LlamaCppDriver>((ref) {
  final driver = LlamaCppDriver();
  ref.onDispose(() {
    driver.dispose();
  });
  return driver;
});

// Repository Provider
final llmEngineRepositoryProvider = Provider<LlmEngineRepository>((ref) {
  final driver = ref.watch(llamaCppDriverProvider);
  return LlmEngineRepositoryImpl(driver);
});
