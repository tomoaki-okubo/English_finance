import 'dart:async';
import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';

enum ModelDownloadStatus { checking, notDownloaded, downloading, ready, error }

class ModelDownloadState {
  final ModelDownloadStatus status;
  final double progress; // 0.0 to 1.0
  final int downloadedBytes;
  final int totalBytes;
  final String? filePath;
  final String? errorMessage;
  final bool justFinishedDownloading;

  ModelDownloadState({
    required this.status,
    required this.progress,
    required this.downloadedBytes,
    required this.totalBytes,
    this.filePath,
    this.errorMessage,
    this.justFinishedDownloading = false,
  });

  ModelDownloadState copyWith({
    ModelDownloadStatus? status,
    double? progress,
    int? downloadedBytes,
    int? totalBytes,
    String? filePath,
    String? errorMessage,
    bool? justFinishedDownloading,
  }) {
    return ModelDownloadState(
      status: status ?? this.status,
      progress: progress ?? this.progress,
      downloadedBytes: downloadedBytes ?? this.downloadedBytes,
      totalBytes: totalBytes ?? this.totalBytes,
      filePath: filePath ?? this.filePath,
      errorMessage: errorMessage ?? this.errorMessage,
      justFinishedDownloading: justFinishedDownloading ?? this.justFinishedDownloading,
    );
  }
}

final modelDownloaderProvider = StateNotifierProvider<ModelDownloaderService, ModelDownloadState>((ref) {
  return ModelDownloaderService();
});

class ModelDownloaderService extends StateNotifier<ModelDownloadState> {
  // Qwen2.5-Coder-0.5B-Instruct-Q4_K_M GGUF (Lightweight, High-performance IT/Coding Model ~398MB)
  static const String modelUrl = 'https://huggingface.co/Qwen/Qwen2.5-Coder-0.5B-Instruct-GGUF/resolve/main/qwen2.5-coder-0.5b-instruct-q4_k_m.gguf';
  static const String modelFileName = 'qwen2.5-coder-0.5b-instruct-q4_k_m.gguf';

  ModelDownloaderService()
      : super(ModelDownloadState(
          status: ModelDownloadStatus.checking,
          progress: 0.0,
          downloadedBytes: 0,
          totalBytes: 0,
        )) {
    checkExistingModel();
  }

  Future<String> getModelFilePath() async {
    final dir = await getApplicationDocumentsDirectory();
    return '${dir.path}/$modelFileName';
  }

  Future<void> checkExistingModel() async {
    try {
      final path = await getModelFilePath();
      final file = File(path);
      if (await file.exists()) {
        final length = await file.length();
        // Check if file is at least 300MB
        if (length > 300 * 1024 * 1024) {
          state = state.copyWith(
            status: ModelDownloadStatus.ready,
            progress: 1.0,
            downloadedBytes: length,
            totalBytes: length,
            filePath: path,
          );
          return;
        }
      }
      state = state.copyWith(status: ModelDownloadStatus.notDownloaded, filePath: path);
    } catch (_) {}
  }

  Future<void> startDownload() async {
    if (state.status == ModelDownloadStatus.downloading || state.status == ModelDownloadStatus.ready) {
      return;
    }

    try {
      final path = await getModelFilePath();
      final file = File(path);
      if (await file.exists()) {
        await file.delete();
      }

      state = state.copyWith(
        status: ModelDownloadStatus.downloading,
        progress: 0.0,
        downloadedBytes: 0,
        filePath: path,
      );

      final client = HttpClient();
      final request = await client.getUrl(Uri.parse(modelUrl));
      request.followRedirects = true;
      request.maxRedirects = 10;
      final response = await request.close();

      if (response.statusCode != 200) {
        throw Exception('Download failed with HTTP status code ${response.statusCode}');
      }

      final totalBytes = response.contentLength;
      int downloadedBytes = 0;

      final sink = file.openWrite();
      await for (final chunk in response) {
        sink.add(chunk);
        downloadedBytes += chunk.length;
        final progress = totalBytes > 0 ? (downloadedBytes / totalBytes) : 0.0;

        state = state.copyWith(
          progress: progress,
          downloadedBytes: downloadedBytes,
          totalBytes: totalBytes,
        );
      }

      await sink.close();
      client.close();

      state = state.copyWith(
        status: ModelDownloadStatus.ready,
        progress: 1.0,
        downloadedBytes: downloadedBytes,
        totalBytes: downloadedBytes,
        filePath: path,
        justFinishedDownloading: true,
      );
    } catch (e) {
      state = state.copyWith(
        status: ModelDownloadStatus.error,
        errorMessage: e.toString(),
        justFinishedDownloading: false,
      );
    }
  }
}
