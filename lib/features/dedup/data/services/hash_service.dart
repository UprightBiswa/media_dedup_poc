import 'dart:io';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:image/image.dart' as img;
import 'package:media_dedup_poc/features/media_scan/domain/models/media_item.dart';

class HashService {
  Future<MediaItem> enrich(MediaItem item) async {
    final bytes = Uint8List.fromList(await File(item.path).readAsBytes());
    final decoded = img.decodeImage(bytes);
    if (decoded == null) {
      return item.copyWith(analysisStatus: AnalysisStatus.failed);
    }

    return item.copyWith(
      sha256: sha256.convert(bytes).toString(),
      perceptualHash: _differenceHash(decoded),
      analysisStatus: AnalysisStatus.hashed,
    );
  }

  BigInt _differenceHash(img.Image image) {
    final resized = img.copyResize(
      img.grayscale(image),
      width: 9,
      height: 8,
      interpolation: img.Interpolation.linear,
    );

    var hash = BigInt.zero;
    var bitIndex = 0;

    for (var y = 0; y < resized.height; y++) {
      for (var x = 0; x < resized.width - 1; x++) {
        final left = resized.getPixel(x, y).luminance;
        final right = resized.getPixel(x + 1, y).luminance;
        if (left > right) {
          hash |= BigInt.one << bitIndex;
        }
        bitIndex++;
      }
    }

    return hash;
  }

  int hammingDistance(BigInt a, BigInt b) {
    var xor = a ^ b;
    var count = 0;
    while (xor > BigInt.zero) {
      count++;
      xor &= xor - BigInt.one;
    }
    return count;
  }
}
