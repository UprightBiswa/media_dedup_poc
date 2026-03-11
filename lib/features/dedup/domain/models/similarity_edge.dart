enum SimilarityType { exactDuplicate, nearDuplicate, semanticSimilar }

class SimilarityEdge {
  SimilarityEdge({
    required this.sourceId,
    required this.targetId,
    required this.similarityType,
    required this.score,
  });

  final String sourceId;
  final String targetId;
  final SimilarityType similarityType;
  final double score;
}
