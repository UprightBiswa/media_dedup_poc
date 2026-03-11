import 'package:media_dedup_poc/features/media_scan/domain/models/media_item.dart';
import 'package:media_dedup_poc/features/similarity/domain/models/similarity_cluster.dart';

enum ProcessingStage {
  idle,
  requestingPermission,
  selectingSource,
  scanning,
  hashing,
  embedding,
  comparing,
  clustering,
  completed,
  failed,
  cancelled,
}

class ProcessingJob {
  const ProcessingJob({
    required this.stage,
    required this.message,
    required this.progress,
    required this.selectedSource,
    required this.items,
    required this.clusters,
    required this.failureReason,
  });

  const ProcessingJob.initial()
      : stage = ProcessingStage.idle,
        message = 'Select a folder to start analysis.',
        progress = 0,
        selectedSource = null,
        items = const [],
        clusters = const [],
        failureReason = null;

  final ProcessingStage stage;
  final String message;
  final double progress;
  final String? selectedSource;
  final List<MediaItem> items;
  final List<SimilarityCluster> clusters;
  final String? failureReason;

  bool get isRunning =>
      stage == ProcessingStage.requestingPermission ||
      stage == ProcessingStage.selectingSource ||
      stage == ProcessingStage.scanning ||
      stage == ProcessingStage.hashing ||
      stage == ProcessingStage.embedding ||
      stage == ProcessingStage.comparing ||
      stage == ProcessingStage.clustering;

  ProcessingJob copyWith({
    ProcessingStage? stage,
    String? message,
    double? progress,
    String? selectedSource,
    List<MediaItem>? items,
    List<SimilarityCluster>? clusters,
    String? failureReason,
    bool clearFailureReason = false,
  }) {
    return ProcessingJob(
      stage: stage ?? this.stage,
      message: message ?? this.message,
      progress: progress ?? this.progress,
      selectedSource: selectedSource ?? this.selectedSource,
      items: items ?? this.items,
      clusters: clusters ?? this.clusters,
      failureReason: clearFailureReason ? null : failureReason ?? this.failureReason,
    );
  }
}
