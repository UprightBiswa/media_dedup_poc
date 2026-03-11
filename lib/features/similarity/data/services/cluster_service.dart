import 'package:collection/collection.dart';
import 'package:media_dedup_poc/features/dedup/domain/models/similarity_edge.dart';
import 'package:media_dedup_poc/features/media_scan/domain/models/media_item.dart';
import 'package:media_dedup_poc/features/similarity/domain/models/similarity_cluster.dart';
import 'package:media_dedup_poc/features/synthesis/data/services/synthesis_service.dart';

class ClusterService {
  ClusterService(this._synthesisService);

  final SynthesisService _synthesisService;

  List<SimilarityCluster> buildClusters({
    required List<MediaItem> items,
    required List<SimilarityEdge> edges,
  }) {
    final itemById = {for (final item in items) item.id: item};
    final grouped = groupBy(edges, (edge) => edge.similarityType);
    final clusters = <SimilarityCluster>[];

    for (final entry in grouped.entries) {
      final parent = <String, String>{for (final item in items) item.id: item.id};

      String find(String id) {
        final root = parent[id]!;
        if (root == id) {
          return id;
        }
        parent[id] = find(root);
        return parent[id]!;
      }

      void union(String a, String b) {
        final rootA = find(a);
        final rootB = find(b);
        if (rootA != rootB) {
          parent[rootB] = rootA;
        }
      }

      for (final edge in entry.value) {
        union(edge.sourceId, edge.targetId);
      }

      final clusterMembers = <String, List<String>>{};
      for (final edge in entry.value) {
        final root = find(edge.sourceId);
        clusterMembers.putIfAbsent(root, () => []);
        clusterMembers[root]!.add(edge.sourceId);
        clusterMembers[root]!.add(edge.targetId);
      }

      for (final ids in clusterMembers.values) {
        final uniqueIds = ids.toSet().toList(growable: false);
        if (uniqueIds.length < 2) {
          continue;
        }

        final clusterItems = uniqueIds.map((id) => itemById[id]!).toList()
          ..sort((a, b) => b.sizeBytes.compareTo(a.sizeBytes));
        final clusterEdges = entry.value
            .where((edge) => uniqueIds.contains(edge.sourceId) && uniqueIds.contains(edge.targetId))
            .toList(growable: false);
        final reclaimableBytes = clusterItems.skip(1).fold<int>(0, (sum, item) => sum + item.sizeBytes);
        final averageScore = clusterEdges.isEmpty ? 0.0 : clusterEdges.map((edge) => edge.score).average;
        final synthesis = _synthesisService.synthesize(
          type: entry.key,
          items: clusterItems,
        );

        clusters.add(
          SimilarityCluster(
            clusterId: '${entry.key.name}_${clusterItems.first.id.hashCode}',
            clusterType: entry.key,
            representative: clusterItems.first,
            items: clusterItems,
            edges: clusterEdges,
            reclaimableBytesEstimate: reclaimableBytes,
            synthesisTitle: synthesis.title,
            synthesisSubtitle: synthesis.subtitle,
            averageScore: averageScore,
          ),
        );
      }
    }

    clusters.sort((a, b) => b.items.length.compareTo(a.items.length));
    return clusters;
  }
}
