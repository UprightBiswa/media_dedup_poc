import 'package:get/get.dart';
import 'package:media_dedup_poc/core/services/processing_orchestrator.dart';
import 'package:media_dedup_poc/features/dedup/domain/models/similarity_edge.dart';
import 'package:media_dedup_poc/features/similarity/data/services/embedding_service.dart';
import 'package:media_dedup_poc/features/similarity/domain/models/similarity_cluster.dart';
import 'package:media_dedup_poc/shared/models/processing_job.dart';

class ScanController extends GetxController {
  ScanController({required ProcessingOrchestrator orchestrator})
      : _orchestrator = orchestrator;

  final ProcessingOrchestrator _orchestrator;
  final EmbeddingService _embeddingService = Get.find<EmbeddingService>();

  @override
  void onInit() {
    super.onInit();
    ever<ProcessingJob>(_orchestrator.currentJob, (_) => update());
  }

  ProcessingJob get job => _orchestrator.currentJob.value;
  String? get selectedDirectory => job.selectedSource;
  String get stageLabel => job.stage.name;
  String get progressMessage => job.message;
  bool get isAnalyzing => job.isRunning;
  double get progress => job.progress;
  int get scannedCount => job.items.length;
  List<SimilarityCluster> get clusters => job.clusters;
  int get exactClusterCount =>
      _orchestrator.countByType(SimilarityType.exactDuplicate);
  int get nearClusterCount =>
      _orchestrator.countByType(SimilarityType.nearDuplicate);
  int get semanticClusterCount =>
      _orchestrator.countByType(SimilarityType.semanticSimilar);
  int get potentialSavingsBytes => _orchestrator.potentialSavingsBytes;
  String get embeddingBackendLabel => _embeddingService.backendLabel;
  String get embeddingBackendDiagnostics => _embeddingService.backendDiagnostics;

  Future<void> pickFolder() async {
    await _orchestrator.selectFolder();
    update();
  }

  Future<void> analyzeSelectedFolder() async {
    if (selectedDirectory == null || selectedDirectory!.isEmpty) {
      Get.snackbar('Folder required', 'Pick a folder before starting analysis.');
      return;
    }

    try {
      await _orchestrator.analyzeSelectedFolder();
    } catch (error) {
      Get.snackbar('Analysis failed', '$error');
    }
    update();
  }
}
