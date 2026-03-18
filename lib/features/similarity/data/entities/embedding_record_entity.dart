import 'package:objectbox/objectbox.dart';

@Entity()
class EmbeddingRecordEntity {
  EmbeddingRecordEntity({
    this.id = 0,
    required this.mediaPath,
    required this.contentVersionKey,
    required this.modelName,
    required this.vectorDimension,
    required this.embeddingJson,
    required this.backend,
    required this.createdAtEpochMs,
    required this.updatedAtEpochMs,
  });

  @Id()
  int id;

  @Unique()
  String mediaPath;

  String contentVersionKey;
  String modelName;
  int vectorDimension;
  String embeddingJson;
  String backend;
  int createdAtEpochMs;
  int updatedAtEpochMs;
}
