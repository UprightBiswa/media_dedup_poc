import 'package:get/get.dart';
import 'package:media_dedup_poc/core/logging/app_logger.dart';
import 'package:media_dedup_poc/core/services/processing_orchestrator.dart';
import 'package:media_dedup_poc/features/dedup/data/services/hash_service.dart';
import 'package:media_dedup_poc/features/media_picker/data/services/media_source_service.dart';
import 'package:media_dedup_poc/features/media_scan/data/services/file_scan_service.dart';
import 'package:media_dedup_poc/features/media_scan/presentation/controllers/scan_controller.dart';
import 'package:media_dedup_poc/features/permissions/data/services/media_permission_service.dart';
import 'package:media_dedup_poc/features/similarity/data/services/cluster_service.dart';
import 'package:media_dedup_poc/features/similarity/data/services/embedding_service.dart';
import 'package:media_dedup_poc/features/similarity/data/services/similarity_service.dart';
import 'package:media_dedup_poc/features/synthesis/data/services/synthesis_service.dart';

class InitialBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(AppLogger(), permanent: true);
    Get.put(
      MediaPermissionService(logger: Get.find<AppLogger>()),
      permanent: true,
    );
    Get.put(
      MediaSourceService(logger: Get.find<AppLogger>()),
      permanent: true,
    );
    Get.put(FileScanService(), permanent: true);
    Get.put(HashService(), permanent: true);
    Get.put(EmbeddingService(), permanent: true);
    Get.put(
      SimilarityService(
        hashService: Get.find<HashService>(),
        embeddingService: Get.find<EmbeddingService>(),
      ),
      permanent: true,
    );
    Get.put(ClusterService(SynthesisService()), permanent: true);
    Get.put(
      ProcessingOrchestrator(
        logger: Get.find<AppLogger>(),
        permissionService: Get.find<MediaPermissionService>(),
        mediaSourceService: Get.find<MediaSourceService>(),
        fileScanService: Get.find<FileScanService>(),
        hashService: Get.find<HashService>(),
        embeddingService: Get.find<EmbeddingService>(),
        similarityService: Get.find<SimilarityService>(),
        clusterService: Get.find<ClusterService>(),
      ),
      permanent: true,
    );
    Get.put(
      ScanController(orchestrator: Get.find<ProcessingOrchestrator>()),
      permanent: true,
    );
  }
}
