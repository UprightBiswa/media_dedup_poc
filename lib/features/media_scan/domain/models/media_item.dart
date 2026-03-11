enum AnalysisStatus { pending, scanned, hashed, embedded, clustered, failed }

class MediaItem {
  MediaItem({
    required this.id,
    required this.path,
    required this.fileName,
    required this.mimeType,
    required this.sizeBytes,
    required this.width,
    required this.height,
    required this.createdAt,
    required this.modifiedAt,
    required this.sha256,
    required this.perceptualHash,
    required this.embedding,
    required this.analysisStatus,
    this.thumbnailPath,
  });

  final String id;
  final String path;
  final String fileName;
  final String mimeType;
  final int sizeBytes;
  final int width;
  final int height;
  final DateTime createdAt;
  final DateTime modifiedAt;
  final String sha256;
  final BigInt perceptualHash;
  final List<double> embedding;
  final String? thumbnailPath;
  final AnalysisStatus analysisStatus;

  bool get hasEmbedding => embedding.isNotEmpty;

  MediaItem copyWith({
    String? sha256,
    BigInt? perceptualHash,
    List<double>? embedding,
    AnalysisStatus? analysisStatus,
    String? thumbnailPath,
  }) {
    return MediaItem(
      id: id,
      path: path,
      fileName: fileName,
      mimeType: mimeType,
      sizeBytes: sizeBytes,
      width: width,
      height: height,
      createdAt: createdAt,
      modifiedAt: modifiedAt,
      sha256: sha256 ?? this.sha256,
      perceptualHash: perceptualHash ?? this.perceptualHash,
      embedding: embedding ?? this.embedding,
      analysisStatus: analysisStatus ?? this.analysisStatus,
      thumbnailPath: thumbnailPath ?? this.thumbnailPath,
    );
  }
}
