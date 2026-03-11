import 'package:path/path.dart' as p;
import 'package:media_dedup_poc/features/dedup/domain/models/similarity_edge.dart';
import 'package:media_dedup_poc/features/media_scan/domain/models/media_item.dart';

class ClusterSynthesis {
  ClusterSynthesis({
    required this.title,
    required this.subtitle,
  });

  final String title;
  final String subtitle;
}

class SynthesisService {
  ClusterSynthesis synthesize({
    required SimilarityType type,
    required List<MediaItem> items,
  }) {
    final representative = items.first;
    final directory = p.basename(p.dirname(representative.path));
    final commonToken = _commonToken(items);

    switch (type) {
      case SimilarityType.exactDuplicate:
        return ClusterSynthesis(
          title: '${items.length} exact copies of the same image',
          subtitle: commonToken == null ? 'Likely downloaded or re-saved in $directory' : 'Shared file pattern: $commonToken',
        );
      case SimilarityType.nearDuplicate:
        return ClusterSynthesis(
          title: '${items.length} near-duplicate image variants',
          subtitle: commonToken == null ? 'Likely edits, forwards, or resized exports from $directory' : 'Likely variations of "$commonToken"',
        );
      case SimilarityType.semanticSimilar:
        return ClusterSynthesis(
          title: '${items.length} visually similar images',
          subtitle: commonToken == null ? 'Grouped by semantic similarity in $directory' : 'Recurring subject hint: $commonToken',
        );
    }
  }

  String? _commonToken(List<MediaItem> items) {
    final tokens = items
        .map((item) => p.basenameWithoutExtension(item.fileName).split(RegExp(r'[_\-\s]+')))
        .expand((values) => values)
        .where((token) => token.length > 2)
        .map((token) => token.toLowerCase())
        .toList();

    return tokens.isEmpty ? null : tokens.first;
  }
}
