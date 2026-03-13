import 'dart:async';

import 'package:get/get.dart';
import 'package:media_dedup_poc/core/database/repositories/processing_job_repository.dart';
import 'package:media_dedup_poc/core/logging/app_logger.dart';
import 'package:media_dedup_poc/features/dedup/data/services/hash_service.dart';
import 'package:media_dedup_poc/features/dedup/domain/models/similarity_edge.dart';
import 'package:media_dedup_poc/features/media_picker/data/services/media_source_service.dart';
import 'package:media_dedup_poc/features/media_scan/data/repositories/media_repository.dart';
import 'package:media_dedup_poc/features/media_scan/data/services/file_scan_service.dart';
import 'package:media_dedup_poc/features/media_scan/data/services/thumbnail_cache_service.dart';
import 'package:media_dedup_poc/features/media_scan/domain/models/media_item.dart';
import 'package:media_dedup_poc/features/permissions/data/services/media_permission_service.dart';
import 'package:media_dedup_poc/features/similarity/data/services/cluster_service.dart';
import 'package:media_dedup_poc/features/similarity/data/services/embedding_service.dart';
import 'package:media_dedup_poc/features/similarity/data/services/similarity_service.dart';
import 'package:media_dedup_poc/features/similarity/domain/models/similarity_cluster.dart';
import 'package:media_dedup_poc/shared/models/processing_job.dart';

class ProcessingOrchestrator extends GetxService {
  ProcessingOrchestrator({
    required AppLogger logger,
    required MediaPermissionService permissionService,
    required MediaSourceService mediaSourceService,
    required FileScanService fileScanService,
    required ThumbnailCacheService thumbnailCacheService,
    required MediaRepository mediaRepository,
    required ProcessingJobRepository processingJobRepository,
    required HashService hashService,
    required EmbeddingService embeddingService,
    required SimilarityService similarityService,
    required ClusterService clusterService,
  })  : _logger = logger,
        _permissionService = permissionService,
        _mediaSourceService = mediaSourceService,
        _fileScanService = fileScanService,
        _thumbnailCacheService = thumbnailCacheService,
        _mediaRepository = mediaRepository,
        _processingJobRepository = processingJobRepository,
        _hashService = hashService,
        _embeddingService = embeddingService,
        _similarityService = similarityService,
        _clusterService = clusterService;

  final AppLogger _logger;
  final MediaPermissionService _permissionService;
  final MediaSourceService _mediaSourceService;
  final FileScanService _fileScanService;
  final ThumbnailCacheService _thumbnailCacheService;
  final MediaRepository _mediaRepository;
  final ProcessingJobRepository _processingJobRepository;
  final HashService _hashService;
  final EmbeddingService _embeddingService;
  final SimilarityService _similarityService;
  final ClusterService _clusterService;

  final Rx<ProcessingJob> currentJob = const ProcessingJob.initial().obs;

  @override
  void onInit() {
    super.onInit();
    unawaited(_restorePersistedJob());
  }

  Future<void> _restorePersistedJob() async {
    final persistedJob = await _processingJobRepository.load();
    final selectedSource = persistedJob.selectedSource;
    if (selectedSource == null || selectedSource.isEmpty) {
      currentJob.value = persistedJob;
      return;
    }

    final items = await _mediaRepository.fetchAllForSource(selectedSource);
    final clusters = _rebuildClusters(items);
    currentJob.value = persistedJob.copyWith(
      items: items,
      clusters: clusters,
      message: items.isEmpty
          ? persistedJob.message
          : 'Reloaded ${items.length} indexed images from local cache',
    );
  }

  Future<void> selectFolder() async {
    _setJob(
      currentJob.value.copyWith(
        stage: ProcessingStage.selectingSource,
        message: 'Waiting for folder selection',
        clearFailureReason: true,
      ),
    );

    final selected = await _mediaSourceService.pickDirectory();
    if (selected == null || selected.isEmpty) {
      _setJob(
        currentJob.value.copyWith(
          stage: ProcessingStage.idle,
          message: 'Folder selection cancelled.',
        ),
      );
      return;
    }

    _setJob(
      currentJob.value.copyWith(
        stage: ProcessingStage.idle,
        selectedSource: selected,
        message: 'Selected folder: $selected',
        clearFailureReason: true,
      ),
    );
  }

  Future<void> analyzeSelectedFolder() async {
    final selectedSource = currentJob.value.selectedSource;
    if (selectedSource == null || selectedSource.isEmpty) {
      throw StateError('Select a folder before starting analysis.');
    }
    _embeddingService.resetRunStats();
    await _embeddingService.probeBackend();

    _setJob(
      currentJob.value.copyWith(
        stage: ProcessingStage.requestingPermission,
        progress: 0,
        items: const [],
        clusters: const [],
        message: 'Checking media permissions',
        clearFailureReason: true,
      ),
    );

    final granted = await _permissionService.requestMediaAccess(
      allowUserSelectedFolderFallback: true,
    );
    if (!granted) {
      _setJob(
        currentJob.value.copyWith(
          stage: ProcessingStage.failed,
          message: 'Media access permission was denied.',
          failureReason: 'Permission denied',
        ),
      );
      return;
    }

    try {
      _setJob(
        currentJob.value.copyWith(
          stage: ProcessingStage.scanning,
          progress: 0.1,
          message: 'Scanning images from $selectedSource',
        ),
      );

      final existingItems = await _mediaRepository.fetchAllForSource(selectedSource);
      final existingItemsByPath = {
        for (final item in existingItems) item.path: item,
      };
      final scanned = await _fileScanService.scanDirectory(
        selectedSource,
        existingItemsByPath: existingItemsByPath,
      );
      final persistedScanned = await _mediaRepository.upsertScannedItems(
        scanned,
        sourceRoot: selectedSource,
      );
      await _mediaRepository.removeMissingItems(
        selectedSource,
        persistedScanned.map((item) => item.path).toSet(),
      );
      final thumbnailReady = <MediaItem>[];
      _setJob(
        currentJob.value.copyWith(
          stage: ProcessingStage.scanning,
          progress: 0.2,
          items: persistedScanned,
          message: 'Generating cached thumbnails',
        ),
      );
      for (final item in persistedScanned) {
        thumbnailReady.add(await _thumbnailCacheService.ensureThumbnail(item));
      }
      await _mediaRepository.saveAnalysisResults(thumbnailReady);
      _setJob(
        currentJob.value.copyWith(
          stage: ProcessingStage.hashing,
          progress: 0.35,
          items: thumbnailReady,
          message:
              'Computing SHA-256 and perceptual hashes for ${thumbnailReady.length} images',
        ),
      );

      final hashed = <MediaItem>[];
      final pendingHashes =
          await _mediaRepository.fetchPendingHashItems(selectedSource);
      final reusableItems = thumbnailReady
          .where((item) => item.sha256.isNotEmpty)
          .toList(growable: false);
      for (final item in pendingHashes) {
        hashed.add(await _hashService.enrich(item));
      }
      hashed.addAll(reusableItems);
      await _mediaRepository.saveAnalysisResults(hashed);

      _setJob(
        currentJob.value.copyWith(
          stage: ProcessingStage.embedding,
          progress: 0.6,
          items: hashed,
          message: 'Building local image embeddings',
        ),
      );

      final embedded = <MediaItem>[];
      final pendingEmbeddings =
          await _mediaRepository.fetchPendingEmbeddingItems(selectedSource);
      final reusableEmbeddings = hashed
          .where((item) => item.embedding.isNotEmpty)
          .toList(growable: false);
      for (final item in pendingEmbeddings) {
        embedded.add(await _embeddingService.enrich(item));
      }
      embedded.addAll(reusableEmbeddings);
      await _mediaRepository.saveAnalysisResults(embedded);

      _setJob(
        currentJob.value.copyWith(
          stage: ProcessingStage.comparing,
          progress: 0.8,
          items: embedded,
          message: 'Comparing candidate pairs',
        ),
      );

      final edges = _similarityService.buildEdges(embedded);
      _setJob(
        currentJob.value.copyWith(
          stage: ProcessingStage.clustering,
          progress: 0.9,
          message: 'Building similarity clusters',
        ),
      );
      final results = _clusterService.buildClusters(items: embedded, edges: edges);

      _setJob(
        currentJob.value.copyWith(
          stage: ProcessingStage.completed,
          progress: 1,
          items: embedded,
          clusters: results,
          message: 'Built ${results.length} clusters from ${embedded.length} images',
        ),
      );
    } catch (error, stackTrace) {
      _logger.error('ProcessingOrchestrator', 'Analysis failed', error, stackTrace);
      _setJob(
        currentJob.value.copyWith(
          stage: ProcessingStage.failed,
          message: 'Analysis failed: $error',
          failureReason: '$error',
        ),
      );
    }
  }

  int countByType(SimilarityType type) {
    return currentJob.value.clusters.where((cluster) => cluster.clusterType == type).length;
  }

  int get potentialSavingsBytes {
    return currentJob.value.clusters.fold<int>(
      0,
      (sum, cluster) => sum + cluster.reclaimableBytesEstimate,
    );
  }

  List<SimilarityCluster> _rebuildClusters(List<MediaItem> items) {
    if (items.length < 2) {
      return const <SimilarityCluster>[];
    }
    final edges = _similarityService.buildEdges(items);
    return _clusterService.buildClusters(items: items, edges: edges);
  }

  void _setJob(ProcessingJob job) {
    currentJob.value = job;
    unawaited(_processingJobRepository.save(job));
  }
}
