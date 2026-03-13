import 'dart:io';

import 'package:image/image.dart' as img;
import 'package:path/path.dart' as p;
import 'package:media_dedup_poc/features/media_scan/domain/models/media_item.dart';

class FileScanService {
  static const _supportedExtensions = {
    '.jpg',
    '.jpeg',
    '.png',
    '.webp',
    '.heic',
    '.bmp',
  };

  Future<List<MediaItem>> scanDirectory(
    String directoryPath, {
    Map<String, MediaItem> existingItemsByPath = const {},
  }) async {
    final directory = Directory(directoryPath);
    if (!await directory.exists()) {
      return [];
    }

    final items = <MediaItem>[];
    await for (final entity in directory.list(recursive: true, followLinks: false)) {
      if (entity is! File || p.basename(entity.path).startsWith('.')) {
        continue;
      }

      final extension = p.extension(entity.path).toLowerCase();
      if (!_supportedExtensions.contains(extension)) {
        continue;
      }

      final stat = await entity.stat();
      final existing = existingItemsByPath[entity.path];
      if (existing != null &&
          existing.sizeBytes == stat.size &&
          existing.modifiedAt.millisecondsSinceEpoch ==
              stat.modified.millisecondsSinceEpoch) {
        items.add(existing);
        continue;
      }

      final bytes = await entity.readAsBytes();
      final decoded = img.decodeImage(bytes);
      if (decoded == null) {
        continue;
      }
      items.add(
        MediaItem(
          id: entity.path,
          path: entity.path,
          fileName: p.basename(entity.path),
          mimeType: 'image/${p.extension(entity.path).replaceFirst('.', '')}',
          sizeBytes: stat.size,
          width: decoded.width,
          height: decoded.height,
          createdAt: stat.changed,
          modifiedAt: stat.modified,
          sha256: '',
          perceptualHash: BigInt.zero,
          embedding: const [],
          analysisStatus: AnalysisStatus.scanned,
        ),
      );
    }

    return items;
  }
}
