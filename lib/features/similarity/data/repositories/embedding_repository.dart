import 'dart:convert';

import 'package:media_dedup_poc/core/database/objectbox_service.dart';
import 'package:media_dedup_poc/features/media_scan/data/repositories/media_repository.dart';
import 'package:media_dedup_poc/features/media_scan/domain/models/media_item.dart';
import 'package:media_dedup_poc/features/similarity/data/entities/embedding_record_entity.dart';
import 'package:media_dedup_poc/features/similarity/data/services/embedding_service.dart';
import 'package:media_dedup_poc/objectbox.g.dart';

class EmbeddingRepository {
  EmbeddingRepository(
    ObjectBoxService objectBoxService, {
    required MediaRepository mediaRepository,
  })  : _box = objectBoxService.store.box<EmbeddingRecordEntity>(),
        _mediaRepository = mediaRepository;

  final Box<EmbeddingRecordEntity> _box;
  final MediaRepository _mediaRepository;

  List<double>? findCachedVector(
    MediaItem item, {
    required String preferredModelName,
  }) {
    final query = _box.query(EmbeddingRecordEntity_.mediaPath.equals(item.path)).build();
    try {
      final record = query.findFirst();
      if (record == null) {
        return null;
      }
      final contentVersionKey = _mediaRepository.buildContentVersionKey(item);
      if (record.contentVersionKey != contentVersionKey) {
        return null;
      }
      if (record.modelName != preferredModelName) {
        return null;
      }
      return (jsonDecode(record.embeddingJson) as List<dynamic>)
          .map((value) => (value as num).toDouble())
          .toList(growable: false);
    } finally {
      query.close();
    }
  }

  Future<void> saveEmbedding(
    MediaItem item,
    EmbeddingPayload payload,
  ) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    final query = _box.query(EmbeddingRecordEntity_.mediaPath.equals(item.path)).build();
    try {
      final existing = query.findFirst();
      final entity = EmbeddingRecordEntity(
        id: existing?.id ?? 0,
        mediaPath: item.path,
        contentVersionKey: _mediaRepository.buildContentVersionKey(item),
        modelName: payload.modelName,
        vectorDimension: payload.vector.length,
        embeddingJson: jsonEncode(payload.vector),
        backend: payload.backend.name,
        createdAtEpochMs: existing?.createdAtEpochMs ?? now,
        updatedAtEpochMs: now,
      );
      _box.put(entity);
    } finally {
      query.close();
    }
  }

  Future<void> removeMissing(Set<String> validPaths) async {
    final all = _box.getAll();
    for (final record in all) {
      if (validPaths.contains(record.mediaPath)) {
        continue;
      }
      _box.remove(record.id);
    }
  }
}
