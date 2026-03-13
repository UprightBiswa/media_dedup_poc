import 'dart:io';
import 'dart:convert';

import 'package:media_dedup_poc/core/database/objectbox_service.dart';
import 'package:media_dedup_poc/features/media_scan/data/entities/media_item_entity.dart';
import 'package:media_dedup_poc/features/media_scan/domain/models/media_item.dart';
import 'package:media_dedup_poc/objectbox.g.dart';

class MediaRepository {
  MediaRepository(ObjectBoxService objectBoxService)
      : _box = objectBoxService.store.box<MediaItemEntity>();

  final Box<MediaItemEntity> _box;

  Future<List<MediaItem>> upsertScannedItems(
    List<MediaItem> items, {
    required String sourceRoot,
  }) async {
    final results = <MediaItem>[];
    final now = DateTime.now().millisecondsSinceEpoch;

    for (final item in items) {
      final existing = _findByPath(item.path);
      final contentVersionKey = buildContentVersionKey(item);

      if (existing != null && existing.contentVersionKey == contentVersionKey) {
        existing
          ..sourceRoot = sourceRoot
          ..lastScannedAtEpochMs = now;
        _box.put(existing);
        results.add(_toDomain(existing));
        continue;
      }

      final entity = _toEntity(
        item,
        existingId: existing?.id ?? 0,
        sourceRoot: sourceRoot,
        lastScannedAtEpochMs: now,
      );
      _box.put(entity);
      results.add(_toDomain(entity));
    }

    return results;
  }

  Future<void> saveAnalysisResults(List<MediaItem> items) async {
    for (final item in items) {
      final existing = _findByPath(item.path);
      final entity = _toEntity(
        item,
        existingId: existing?.id ?? 0,
        sourceRoot: existing?.sourceRoot,
        lastScannedAtEpochMs:
            existing?.lastScannedAtEpochMs ?? DateTime.now().millisecondsSinceEpoch,
      );
      _box.put(entity);
    }
  }

  Future<List<MediaItem>> fetchAllForSource(String sourceRoot) async {
    final query = _box.query(MediaItemEntity_.sourceRoot.equals(sourceRoot)).build();
    try {
      return query.find().map(_toDomain).toList(growable: false);
    } finally {
      query.close();
    }
  }

  Future<void> removeMissingItems(
    String sourceRoot,
    Set<String> validPaths,
  ) async {
    final query = _box.query(MediaItemEntity_.sourceRoot.equals(sourceRoot)).build();
    try {
      final existing = query.find();
      for (final entity in existing) {
        if (validPaths.contains(entity.path)) {
          continue;
        }
        if (entity.thumbnailPath != null) {
          final thumbnailFile = File(entity.thumbnailPath!);
          if (await thumbnailFile.exists()) {
            await thumbnailFile.delete();
          }
        }
        _box.remove(entity.id);
      }
    } finally {
      query.close();
    }
  }

  Future<List<MediaItem>> fetchPendingHashItems(String sourceRoot) async {
    final query = _box
        .query(
          MediaItemEntity_.sourceRoot.equals(sourceRoot) &
              MediaItemEntity_.sha256.equals(''),
        )
        .build();
    try {
      return query.find().map(_toDomain).toList(growable: false);
    } finally {
      query.close();
    }
  }

  Future<List<MediaItem>> fetchPendingEmbeddingItems(String sourceRoot) async {
    final query = _box
        .query(
          MediaItemEntity_.sourceRoot.equals(sourceRoot) &
              MediaItemEntity_.embeddingJson.equals('[]'),
        )
        .build();
    try {
      return query.find().map(_toDomain).toList(growable: false);
    } finally {
      query.close();
    }
  }

  String buildContentVersionKey(MediaItem item) {
    return '${item.path}|${item.sizeBytes}|${item.modifiedAt.millisecondsSinceEpoch}';
  }

  MediaItemEntity? _findByPath(String path) {
    final query = _box.query(MediaItemEntity_.path.equals(path)).build();
    try {
      return query.findFirst();
    } finally {
      query.close();
    }
  }

  MediaItemEntity _toEntity(
    MediaItem item, {
    required int existingId,
    required String? sourceRoot,
    required int lastScannedAtEpochMs,
  }) {
    return MediaItemEntity(
      id: existingId,
      path: item.path,
      fileName: item.fileName,
      mimeType: item.mimeType,
      sizeBytes: item.sizeBytes,
      width: item.width,
      height: item.height,
      createdAtEpochMs: item.createdAt.millisecondsSinceEpoch,
      modifiedAtEpochMs: item.modifiedAt.millisecondsSinceEpoch,
      contentVersionKey: buildContentVersionKey(item),
      analysisStatus: item.analysisStatus.name,
      sha256: item.sha256,
      perceptualHashHex: item.perceptualHash.toRadixString(16),
      embeddingJson: jsonEncode(item.embedding),
      thumbnailPath: item.thumbnailPath,
      sourceRoot: sourceRoot,
      lastScannedAtEpochMs: lastScannedAtEpochMs,
    );
  }

  MediaItem _toDomain(MediaItemEntity entity) {
    return MediaItem(
      id: entity.path,
      path: entity.path,
      fileName: entity.fileName,
      mimeType: entity.mimeType,
      sizeBytes: entity.sizeBytes,
      width: entity.width,
      height: entity.height,
      createdAt: DateTime.fromMillisecondsSinceEpoch(entity.createdAtEpochMs),
      modifiedAt: DateTime.fromMillisecondsSinceEpoch(entity.modifiedAtEpochMs),
      sha256: entity.sha256,
      perceptualHash: BigInt.parse(entity.perceptualHashHex, radix: 16),
      embedding: (jsonDecode(entity.embeddingJson) as List<dynamic>)
          .map((value) => (value as num).toDouble())
          .toList(growable: false),
      thumbnailPath: entity.thumbnailPath,
      analysisStatus: AnalysisStatus.values.byName(entity.analysisStatus),
    );
  }
}
