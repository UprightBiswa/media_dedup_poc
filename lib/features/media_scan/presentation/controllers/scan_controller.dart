import 'package:file_picker/file_picker.dart';
import 'package:get/get.dart';
import 'package:media_dedup_poc/features/dedup/data/services/hash_service.dart';
import 'package:media_dedup_poc/features/dedup/domain/models/similarity_edge.dart';
import 'package:media_dedup_poc/features/media_scan/data/services/file_scan_service.dart';
import 'package:media_dedup_poc/features/media_scan/domain/models/media_item.dart';
import 'package:media_dedup_poc/features/similarity/data/services/cluster_service.dart';
import 'package:media_dedup_poc/features/similarity/data/services/embedding_service.dart';
import 'package:media_dedup_poc/features/similarity/data/services/similarity_service.dart';
import 'package:media_dedup_poc/features/similarity/domain/models/similarity_cluster.dart';
import 'package:media_dedup_poc/features/synthesis/data/services/synthesis_service.dart';

class ScanController extends GetxController {
  final selectedDirectory = RxnString();
  final stageLabel = 'Idle'.obs;
  final progressMessage = 'Select a folder to start analysis.'.obs;
  final isAnalyzing = false.obs;
  final scannedItems = <MediaItem>[].obs;
  final clusters = <SimilarityCluster>[].obs;
  final exactClusterCount = 0.obs;
  final nearClusterCount = 0.obs;
  final semanticClusterCount = 0.obs;
  final potentialSavingsBytes = 0.obs;

  late final FileScanService _fileScanService;
  late final HashService _hashService;
  late final EmbeddingService _embeddingService;
  late final SimilarityService _similarityService;
  late final ClusterService _clusterService;

  @override
  void onInit() {
    super.onInit();
    _fileScanService = FileScanService();
    _hashService = HashService();
    _embeddingService = EmbeddingService();
    _similarityService = SimilarityService(
      hashService: _hashService,
      embeddingService: _embeddingService,
    );
    _clusterService = ClusterService(SynthesisService());
  }

  Future<void> pickFolder() async {
    final path = await FilePicker.platform.getDirectoryPath(dialogTitle: 'Choose a media folder');
    if (path != null && path.isNotEmpty) {
      selectedDirectory.value = path;
      progressMessage.value = 'Selected folder: $path';
    }
  }

  Future<void> analyzeSelectedFolder() async {
    final directory = selectedDirectory.value;
    if (directory == null || directory.isEmpty) {
      Get.snackbar('Folder required', 'Pick a folder before starting analysis.');
      return;
    }

    isAnalyzing.value = true;
    clusters.clear();
    scannedItems.clear();
    stageLabel.value = 'Scanning';
    progressMessage.value = 'Discovering images in $directory';

    try {
      final scanned = await _fileScanService.scanDirectory(directory);
      scannedItems.assignAll(scanned);
      progressMessage.value = 'Found ${scanned.length} candidate images';

      stageLabel.value = 'Hashing';
      final hashed = <MediaItem>[];
      for (final item in scanned) {
        hashed.add(await _hashService.enrich(item));
      }
      scannedItems.assignAll(hashed);
      progressMessage.value = 'Computed exact and perceptual hashes';

      stageLabel.value = 'Embedding';
      final embedded = <MediaItem>[];
      for (final item in hashed) {
        embedded.add(await _embeddingService.enrich(item));
      }
      scannedItems.assignAll(embedded);
      progressMessage.value = 'Built local similarity vectors';

      stageLabel.value = 'Clustering';
      final edges = _similarityService.buildEdges(embedded);
      final results = _clusterService.buildClusters(
        items: embedded,
        edges: edges,
      );

      clusters.assignAll(results);
      exactClusterCount.value = results.where((cluster) => cluster.clusterType == SimilarityType.exactDuplicate).length;
      nearClusterCount.value = results.where((cluster) => cluster.clusterType == SimilarityType.nearDuplicate).length;
      semanticClusterCount.value = results.where((cluster) => cluster.clusterType == SimilarityType.semanticSimilar).length;
      potentialSavingsBytes.value = results.fold<int>(0, (sum, cluster) => sum + cluster.reclaimableBytesEstimate);
      stageLabel.value = 'Completed';
      progressMessage.value = 'Built ${results.length} similarity clusters from ${embedded.length} images';
    } catch (error) {
      stageLabel.value = 'Failed';
      progressMessage.value = 'Analysis failed: $error';
      Get.snackbar('Analysis failed', '$error');
    } finally {
      isAnalyzing.value = false;
    }
  }
}
