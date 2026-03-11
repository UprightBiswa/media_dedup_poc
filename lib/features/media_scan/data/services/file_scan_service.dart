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

  Future<List<MediaItem>> scanDirectory(String directoryPath) async {
    final directory = Directory(directoryPath);
    if (!await directory.exists()) {
      return [];
    }

    final files = <File>[];
    await for (final entity in directory.list(recursive: true, followLinks: false)) {
      if (entity is! File) {
        continue;
      }

      final extension = p.extension(entity.path).toLowerCase();
      if (_supportedExtensions.contains(extension)) {
        files.add(entity);
      }
    }

    final items = <MediaItem>[];
    for (final file in files) {
      final stat = await file.stat();
      final bytes = await file.readAsBytes();
      final decoded = img.decodeImage(bytes);
      if (decoded == null) {
        continue;
      }

      items.add(
        MediaItem(
          id: file.path,
          path: file.path,
          fileName: p.basename(file.path),
          mimeType: 'image/${p.extension(file.path).replaceFirst('.', '')}',
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
