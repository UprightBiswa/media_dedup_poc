import 'dart:io';
import 'dart:math' as math;

import 'package:get/get.dart';
import 'package:flutter/services.dart';
import 'package:image/image.dart' as img;
import 'package:media_dedup_poc/features/media_scan/domain/models/media_item.dart';

enum EmbeddingBackend {
  unknown,
  nativeMediaPipe,
  heuristicFallback,
}

class EmbeddingService {
  static const _channel = MethodChannel('media_dedup_poc/image_embedder');
  static const modelName = 'mediapipe_mobilenet_v3_small';
  static const fallbackModelName = 'heuristic_image_embedding_v0';
  static const vectorDimension = 18;
  final Rx<EmbeddingBackend> _backend = EmbeddingBackend.unknown.obs;
  final RxInt _nativeSuccessCount = 0.obs;
  final RxInt _fallbackCount = 0.obs;
  final RxnString _lastNativeError = RxnString();
  bool? _isNativeModelReady;

  EmbeddingBackend get currentBackend => _backend.value;
  String get backendLabel {
    if (_nativeSuccessCount.value > 0) {
      return 'MediaPipe';
    }
    if (_fallbackCount.value > 0) {
      return 'Fallback';
    }
    return 'Unknown';
  }

  String get backendDiagnostics {
    final parts = <String>[];
    parts.add('native=${_nativeSuccessCount.value}');
    parts.add('fallback=${_fallbackCount.value}');
    if (_isNativeModelReady != null) {
      parts.add('modelReady=${_isNativeModelReady!}');
    }
    if (_lastNativeError.value != null && _lastNativeError.value!.isNotEmpty) {
      parts.add('error=${_lastNativeError.value}');
    }
    return parts.join(' | ');
  }

  Future<void> probeBackend() async {
    if (!Platform.isAndroid) {
      return;
    }
    try {
      final result = await _channel.invokeMethod<Map<dynamic, dynamic>>(
        'getModelStatus',
      );
      _isNativeModelReady = (result?['ready'] as bool?) ?? false;
      final error = result?['error'] as String?;
      _lastNativeError.value = error;
      if (_isNativeModelReady == true && _nativeSuccessCount.value == 0) {
        _backend.value = EmbeddingBackend.nativeMediaPipe;
      }
    } on PlatformException catch (error) {
      _isNativeModelReady = false;
      _lastNativeError.value = error.message;
    }
  }

  void resetRunStats() {
    _nativeSuccessCount.value = 0;
    _fallbackCount.value = 0;
    _lastNativeError.value = null;
    _backend.value = EmbeddingBackend.unknown;
  }

  Future<MediaItem> enrich(MediaItem item) async {
    if (Platform.isAndroid) {
      try {
        final nativeEmbedding = await _getNativeEmbedding(item.path);
        if (nativeEmbedding.isNotEmpty) {
          _nativeSuccessCount.value++;
          _backend.value = EmbeddingBackend.nativeMediaPipe;
          return item.copyWith(
            embedding: nativeEmbedding,
            analysisStatus: AnalysisStatus.embedded,
          );
        }
      } on PlatformException catch (error) {
        _lastNativeError.value = error.message;
      }
    }

    final bytes = await File(item.path).readAsBytes();
    final source = img.decodeImage(bytes);
    if (source == null) {
      return item.copyWith(analysisStatus: AnalysisStatus.failed);
    }

    final embedding = _buildHeuristicEmbedding(source);
    _fallbackCount.value++;
    if (_nativeSuccessCount.value == 0) {
      _backend.value = EmbeddingBackend.heuristicFallback;
    }
    return item.copyWith(
      embedding: embedding,
      analysisStatus: AnalysisStatus.embedded,
    );
  }

  List<double> _buildHeuristicEmbedding(img.Image source) {
    final resized = img.copyResize(source, width: 24, height: 24);
    final bins = List<double>.filled(vectorDimension, 0);

    for (final pixel in resized) {
      bins[_bucket(pixel.r)] += 1;
      bins[6 + _bucket(pixel.g)] += 1;
      bins[12 + _bucket(pixel.b)] += 1;
    }

    final norm = math.sqrt(bins.fold<double>(0, (sum, value) => sum + value * value));
    if (norm == 0) {
      return bins;
    }

    return bins.map((value) => value / norm).toList(growable: false);
  }

  Future<List<double>> _getNativeEmbedding(String imagePath) async {
    final result = await _channel.invokeMethod<List<dynamic>>(
      'getImageEmbedding',
      {'imagePath': imagePath},
    );
    if (result == null) {
      return const [];
    }
    return result.map((value) => (value as num).toDouble()).toList(growable: false);
  }

  int _bucket(num channel) {
    return (channel ~/ 43).clamp(0, 5);
  }

  double cosineSimilarity(List<double> a, List<double> b) {
    if (a.isEmpty || b.isEmpty || a.length != b.length) {
      return 0;
    }

    var dot = 0.0;
    var magA = 0.0;
    var magB = 0.0;
    for (var i = 0; i < a.length; i++) {
      dot += a[i] * b[i];
      magA += a[i] * a[i];
      magB += b[i] * b[i];
    }

    if (magA == 0 || magB == 0) {
      return 0;
    }

    return dot / (math.sqrt(magA) * math.sqrt(magB));
  }
}
