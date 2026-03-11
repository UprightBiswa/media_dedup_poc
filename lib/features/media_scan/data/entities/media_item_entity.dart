import 'package:objectbox/objectbox.dart';

@Entity()
class MediaItemEntity {
  MediaItemEntity({
    this.id = 0,
    required this.path,
    required this.fileName,
    required this.mimeType,
    required this.sizeBytes,
    required this.width,
    required this.height,
    required this.createdAtEpochMs,
    required this.modifiedAtEpochMs,
    required this.contentVersionKey,
    required this.analysisStatus,
    this.sha256 = '',
    this.perceptualHashHex = '0',
    this.embeddingJson = '[]',
    this.thumbnailPath,
    this.sourceRoot,
    this.lastScannedAtEpochMs = 0,
  });

  @Id()
  int id;

  @Unique()
  String path;

  String fileName;
  String mimeType;
  int sizeBytes;
  int width;
  int height;
  int createdAtEpochMs;
  int modifiedAtEpochMs;
  String contentVersionKey;
  String analysisStatus;
  String sha256;
  String perceptualHashHex;
  String embeddingJson;
  String? thumbnailPath;
  String? sourceRoot;
  int lastScannedAtEpochMs;
}
