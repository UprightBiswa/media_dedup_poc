import 'dart:math' as math;

import 'package:media_dedup_poc/core/constants/analysis_defaults.dart';
import 'package:media_dedup_poc/features/dedup/data/services/hash_service.dart';
import 'package:media_dedup_poc/features/dedup/domain/models/similarity_edge.dart';
import 'package:media_dedup_poc/features/media_scan/domain/models/media_item.dart';
import 'package:media_dedup_poc/features/similarity/data/services/embedding_service.dart';

class SimilarityService {
  SimilarityService({
    required HashService hashService,
    required EmbeddingService embeddingService,
  })  : _hashService = hashService,
        _embeddingService = embeddingService;

  final HashService _hashService;
  final EmbeddingService _embeddingService;

  List<SimilarityEdge> buildEdges(List<MediaItem> items) {
    final edges = <SimilarityEdge>[];

    for (var i = 0; i < items.length; i++) {
      for (var j = i + 1; j < items.length; j++) {
        final left = items[i];
        final right = items[j];

        if (left.sha256.isNotEmpty && left.sha256 == right.sha256) {
          edges.add(
            SimilarityEdge(
              sourceId: left.id,
              targetId: right.id,
              similarityType: SimilarityType.exactDuplicate,
              score: 1,
            ),
          );
          continue;
        }

        final hashDistance = _hashService.hammingDistance(left.perceptualHash, right.perceptualHash);
        final resolutionDelta = ((left.width * left.height) - (right.width * right.height)).abs();
        final maxResolution = math.max(left.width * left.height, right.width * right.height);
        final resolutionScore = maxResolution == 0 ? 0.0 : 1 - (resolutionDelta / maxResolution);
        final sizeScore = 1 - ((left.sizeBytes - right.sizeBytes).abs() / math.max(left.sizeBytes, right.sizeBytes));

        if (hashDistance <= AnalysisDefaults.nearDuplicateHashDistance) {
          final score = ((1 - (hashDistance / 64)) * 0.6) + (resolutionScore * 0.2) + (sizeScore * 0.2);
          edges.add(
            SimilarityEdge(
              sourceId: left.id,
              targetId: right.id,
              similarityType: SimilarityType.nearDuplicate,
              score: score.clamp(0, 1),
            ),
          );
          continue;
        }

        final semanticScore = _embeddingService.cosineSimilarity(left.embedding, right.embedding);
        if (semanticScore >= AnalysisDefaults.semanticSimilarity) {
          edges.add(
            SimilarityEdge(
              sourceId: left.id,
              targetId: right.id,
              similarityType: SimilarityType.semanticSimilar,
              score: semanticScore,
            ),
          );
        }
      }
    }

    return edges;
  }
}
