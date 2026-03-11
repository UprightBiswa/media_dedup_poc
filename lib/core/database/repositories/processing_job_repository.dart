import 'package:media_dedup_poc/core/database/objectbox_service.dart';
import 'package:media_dedup_poc/objectbox.g.dart';
import 'package:media_dedup_poc/shared/entities/processing_job_entity.dart';
import 'package:media_dedup_poc/shared/models/processing_job.dart';

class ProcessingJobRepository {
  ProcessingJobRepository(ObjectBoxService objectBoxService)
      : _box = objectBoxService.store.box<ProcessingJobEntity>();

  final Box<ProcessingJobEntity> _box;
  static const _jobKey = 'active_processing_job';

  Future<void> save(ProcessingJob job) async {
    final existing = _findByKey();
    _box.put(
      ProcessingJobEntity(
        id: existing?.id ?? 0,
        jobKey: _jobKey,
        stage: job.stage.name,
        message: job.message,
        progress: job.progress,
        selectedSource: job.selectedSource,
        failureReason: job.failureReason,
        updatedAtEpochMs: DateTime.now().millisecondsSinceEpoch,
      ),
    );
  }

  Future<ProcessingJob> load() async {
    final entity = _findByKey();
    if (entity == null) {
      return const ProcessingJob.initial();
    }

    return ProcessingJob(
      stage: ProcessingStage.values.byName(entity.stage),
      message: entity.message,
      progress: entity.progress,
      selectedSource: entity.selectedSource,
      items: const [],
      clusters: const [],
      failureReason: entity.failureReason,
    );
  }

  ProcessingJobEntity? _findByKey() {
    final query = _box.query(ProcessingJobEntity_.jobKey.equals(_jobKey)).build();
    try {
      return query.findFirst();
    } finally {
      query.close();
    }
  }
}
