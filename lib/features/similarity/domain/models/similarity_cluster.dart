import 'package:media_dedup_poc/features/dedup/domain/models/similarity_edge.dart';
import 'package:media_dedup_poc/features/media_scan/domain/models/media_item.dart';

class SimilarityCluster {
  SimilarityCluster({
    required this.clusterId,
    required this.clusterType,
    required this.representative,
    required this.items,
    required this.edges,
    required this.reclaimableBytesEstimate,
    required this.synthesisTitle,
    required this.synthesisSubtitle,
    required this.averageScore,
  });

  final String clusterId;
  final SimilarityType clusterType;
  final MediaItem representative;
  final List<MediaItem> items;
  final List<SimilarityEdge> edges;
  final int reclaimableBytesEstimate;
  final String synthesisTitle;
  final String synthesisSubtitle;
  final double averageScore;
}
