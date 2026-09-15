import 'dart:ffi' as ffi;
import 'dart:io';

// --- Opaque Pointers ---
final class LlamaModel extends ffi.Opaque {}
final class LlamaContext extends ffi.Opaque {}
final class LlamaSampler extends ffi.Opaque {}

typedef LlamaToken = ffi.Int32;
typedef LlamaPos = ffi.Int32;
typedef LlamaSeqId = ffi.Int32;

// --- Structs (Simplified representation for common llama.cpp API) ---
final class LlamaModelParams extends ffi.Struct {
  @ffi.Int32()
  external int n_gpu_layers;
  @ffi.Int32()
  external int split_mode;
  @ffi.Int32()
  external int main_gpu;
  external ffi.Pointer<ffi.Float> tensor_split;
  external ffi.Pointer<ffi.Void> progress_callback;
  external ffi.Pointer<ffi.Void> progress_callback_user_data;
  external ffi.Pointer<ffi.Void> kv_overrides;
  @ffi.Bool()
  external bool vocab_only;
  @ffi.Bool()
  external bool use_mmap;
  @ffi.Bool()
  external bool use_mlock;
  @ffi.Bool()
  external bool check_tensors;
}

final class LlamaContextParams extends ffi.Struct {
  @ffi.Uint32()
  external int seed;
  @ffi.Uint32()
  external int n_ctx;
  @ffi.Uint32()
  external int n_batch;
  @ffi.Uint32()
  external int n_ubatch;
  @ffi.Uint32()
  external int n_seq_max;
  @ffi.Uint32()
  external int n_threads;
  @ffi.Uint32()
  external int n_threads_batch;
  @ffi.Int32()
  external int rope_scaling_type;
  @ffi.Int32()
  external int pooling_type;
  @ffi.Int32()
  external int attention_type;
  @ffi.Float()
  external double rope_freq_base;
  @ffi.Float()
  external double rope_freq_scale;
  @ffi.Float()
  external double yarn_ext_factor;
  @ffi.Float()
  external double yarn_attn_factor;
  @ffi.Float()
  external double yarn_beta_fast;
  @ffi.Float()
  external double yarn_beta_slow;
  @ffi.Uint32()
  external int yarn_orig_ctx;
  @ffi.Float()
  external double defrag_thold;
  external ffi.Pointer<ffi.Void> cb_eval;
  external ffi.Pointer<ffi.Void> cb_eval_user_data;
  @ffi.Int32()
  external int type_k;
  @ffi.Int32()
  external int type_v;
  @ffi.Bool()
  external bool logits_all;
  @ffi.Bool()
  external bool embeddings;
  @ffi.Bool()
  external bool offload_kqv;
  @ffi.Bool()
  external bool flash_attn;
  external ffi.Pointer<ffi.Void> abort_callback;
  external ffi.Pointer<ffi.Void> abort_callback_data;
}

final class LlamaBatch extends ffi.Struct {
  @ffi.Int32()
  external int n_tokens;
  external ffi.Pointer<LlamaToken> token;
  external ffi.Pointer<ffi.Float> embd;
  external ffi.Pointer<LlamaPos> pos;
  external ffi.Pointer<ffi.Int32> n_seq_id;
  external ffi.Pointer<ffi.Pointer<LlamaSeqId>> seq_id;
  external ffi.Pointer<ffi.Int8> logits;
  @ffi.Int32()
  external int all_pos_0;
  @ffi.Int32()
  external int all_pos_1;
  @ffi.Int32()
  external int all_seq_id;
}

class LlamaBindings {
  late final ffi.DynamicLibrary _lib;

  LlamaBindings() {
    if (Platform.isMacOS || Platform.isIOS) {
      _lib = ffi.DynamicLibrary.process();
    } else if (Platform.isAndroid || Platform.isLinux) {
      _lib = ffi.DynamicLibrary.open('libllama.so');
    } else if (Platform.isWindows) {
      _lib = ffi.DynamicLibrary.open('llama.dll');
    } else {
      throw UnsupportedError('Unsupported platform');
    }

    _llama_backend_init = _lib.lookupFunction<
        ffi.Void Function(),
        void Function()>('llama_backend_init');
        
    _llama_backend_free = _lib.lookupFunction<
        ffi.Void Function(),
        void Function()>('llama_backend_free');

    _llama_model_default_params = _lib.lookupFunction<
        LlamaModelParams Function(),
        LlamaModelParams Function()>('llama_model_default_params');

    _llama_context_default_params = _lib.lookupFunction<
        LlamaContextParams Function(),
        LlamaContextParams Function()>('llama_context_default_params');

    _llama_load_model_from_file = _lib.lookupFunction<
        ffi.Pointer<LlamaModel> Function(ffi.Pointer<ffi.Char>, LlamaModelParams),
        ffi.Pointer<LlamaModel> Function(ffi.Pointer<ffi.Char>, LlamaModelParams)>('llama_load_model_from_file');

    _llama_new_context_with_model = _lib.lookupFunction<
        ffi.Pointer<LlamaContext> Function(ffi.Pointer<LlamaModel>, LlamaContextParams),
        ffi.Pointer<LlamaContext> Function(ffi.Pointer<LlamaModel>, LlamaContextParams)>('llama_new_context_with_model');

    _llama_free = _lib.lookupFunction<
        ffi.Void Function(ffi.Pointer<LlamaContext>),
        void Function(ffi.Pointer<LlamaContext>)>('llama_free');

    _llama_free_model = _lib.lookupFunction<
        ffi.Void Function(ffi.Pointer<LlamaModel>),
        void Function(ffi.Pointer<LlamaModel>)>('llama_free_model');

    _llama_batch_init = _lib.lookupFunction<
        LlamaBatch Function(ffi.Int32, ffi.Int32, ffi.Int32),
        LlamaBatch Function(int, int, int)>('llama_batch_init');

    _llama_batch_free = _lib.lookupFunction<
        ffi.Void Function(LlamaBatch),
        void Function(LlamaBatch)>('llama_batch_free');
        
    _llama_decode = _lib.lookupFunction<
        ffi.Int32 Function(ffi.Pointer<LlamaContext>, LlamaBatch),
        int Function(ffi.Pointer<LlamaContext>, LlamaBatch)>('llama_decode');
  }

  late final void Function() _llama_backend_init;
  void llama_backend_init() => _llama_backend_init();

  late final void Function() _llama_backend_free;
  void llama_backend_free() => _llama_backend_free();

  late final LlamaModelParams Function() _llama_model_default_params;
  LlamaModelParams llama_model_default_params() => _llama_model_default_params();

  late final LlamaContextParams Function() _llama_context_default_params;
  LlamaContextParams llama_context_default_params() => _llama_context_default_params();

  late final ffi.Pointer<LlamaModel> Function(ffi.Pointer<ffi.Char>, LlamaModelParams) _llama_load_model_from_file;
  ffi.Pointer<LlamaModel> llama_load_model_from_file(ffi.Pointer<ffi.Char> path, LlamaModelParams params) => _llama_load_model_from_file(path, params);

  late final ffi.Pointer<LlamaContext> Function(ffi.Pointer<LlamaModel>, LlamaContextParams) _llama_new_context_with_model;
  ffi.Pointer<LlamaContext> llama_new_context_with_model(ffi.Pointer<LlamaModel> model, LlamaContextParams params) => _llama_new_context_with_model(model, params);

  late final void Function(ffi.Pointer<LlamaContext>) _llama_free;
  void llama_free(ffi.Pointer<LlamaContext> ctx) => _llama_free(ctx);

  late final void Function(ffi.Pointer<LlamaModel>) _llama_free_model;
  void llama_free_model(ffi.Pointer<LlamaModel> model) => _llama_free_model(model);
  
  late final LlamaBatch Function(int, int, int) _llama_batch_init;
  LlamaBatch llama_batch_init(int n_tokens, int embd, int n_seq_max) => _llama_batch_init(n_tokens, embd, n_seq_max);
  
  late final void Function(LlamaBatch) _llama_batch_free;
  void llama_batch_free(LlamaBatch batch) => _llama_batch_free(batch);

  late final int Function(ffi.Pointer<LlamaContext>, LlamaBatch) _llama_decode;
  int llama_decode(ffi.Pointer<LlamaContext> ctx, LlamaBatch batch) => _llama_decode(ctx, batch);
}
