import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:image/image.dart' as img;
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:media_dedup_poc/features/media_scan/domain/models/media_item.dart';

class ThumbnailCacheService {
  Future<MediaItem> ensureThumbnail(MediaItem item) async {
    if (item.thumbnailPath != null && await File(item.thumbnailPath!).exists()) {
      return item;
    }

    final sourceBytes = await File(item.path).readAsBytes();
    final sourceImage = img.decodeImage(sourceBytes);
    if (sourceImage == null) {
      return item;
    }

    final directory = await getApplicationDocumentsDirectory();
    final thumbnailDirectory = Directory(
      p.join(directory.path, 'media_dedup_thumbnails'),
    );
    if (!await thumbnailDirectory.exists()) {
      await thumbnailDirectory.create(recursive: true);
    }

    final fileName = sha1
        .convert(item.path.codeUnits)
        .toString();
    final thumbnailPath = p.join(thumbnailDirectory.path, '$fileName.jpg');
    final resized = img.copyResize(sourceImage, width: 240);
    final thumbnailBytes = img.encodeJpg(resized, quality: 72);
    await File(thumbnailPath).writeAsBytes(thumbnailBytes, flush: true);

    return item.copyWith(thumbnailPath: thumbnailPath);
  }
}
