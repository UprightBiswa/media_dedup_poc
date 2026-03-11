import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:media_dedup_poc/core/utils/formatters.dart';
import 'package:media_dedup_poc/features/media_scan/presentation/controllers/scan_controller.dart';
import 'package:media_dedup_poc/shared/widgets/stat_card.dart';

class DashboardPage extends GetView<ScanController> {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Media De-duplication POC'),
      ),
      body: GetBuilder<ScanController>(
        builder: (_) => ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF0B5D4B), Color(0xFF5E8B7E)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(28),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Offline-first similarity explorer',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Scan a local folder, compute exact hashes, perceptual hashes, and local embeddings, then group related images into explainable clusters.',
                    style: TextStyle(color: Colors.white70),
                  ),
                  const SizedBox(height: 20),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      FilledButton.tonal(
                        onPressed: controller.isAnalyzing ? null : controller.pickFolder,
                        child: const Text('Select Folder'),
                      ),
                      FilledButton(
                        onPressed: controller.isAnalyzing ? null : controller.analyzeSelectedFolder,
                        child: Text(controller.isAnalyzing ? 'Analyzing...' : 'Analyze'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    controller.selectedDirectory ?? 'No folder selected yet.',
                    style: const TextStyle(color: Colors.white),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Card(
              child: ListTile(
                leading: const Icon(Icons.radar),
                title: Text(controller.stageLabel),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(controller.progressMessage),
                    const SizedBox(height: 8),
                    LinearProgressIndicator(value: controller.progress),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            GridView.count(
              crossAxisCount: MediaQuery.of(context).size.width > 800 ? 4 : 2,
              shrinkWrap: true,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              physics: const NeverScrollableScrollPhysics(),
              childAspectRatio: 1,
              children: [
                StatCard(
                  label: 'Images Analyzed',
                  value: '${controller.scannedCount}',
                  icon: Icons.photo_library_outlined,
                ),
                StatCard(
                  label: 'Exact Groups',
                  value: '${controller.exactClusterCount}',
                  icon: Icons.copy_all_outlined,
                ),
                StatCard(
                  label: 'Near-dup Groups',
                  value: '${controller.nearClusterCount}',
                  icon: Icons.filter_none_outlined,
                ),
                StatCard(
                  label: 'Semantic Groups',
                  value: '${controller.semanticClusterCount}',
                  icon: Icons.auto_awesome_outlined,
                ),
              ],
            ),
            const SizedBox(height: 20),
            Card(
              child: ListTile(
                leading: const Icon(Icons.savings_outlined),
                title: const Text('Potential reclaimable storage'),
                subtitle: Text(Formatters.bytes(controller.potentialSavingsBytes)),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Similarity Clusters',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(height: 12),
            if (controller.clusters.isEmpty)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Text(
                    controller.isAnalyzing
                        ? 'Working through the current scan.'
                        : 'No clusters yet. Pick a folder and run analysis.',
                  ),
                ),
              ),
            ...controller.clusters.map(
              (cluster) => Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        cluster.synthesisTitle,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                      const SizedBox(height: 6),
                      Text(cluster.synthesisSubtitle),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          Chip(label: Text(cluster.clusterType.name)),
                          Chip(label: Text('${cluster.items.length} items')),
                          Chip(label: Text('Avg score ${Formatters.percent(cluster.averageScore)}')),
                          Chip(label: Text('Savings ${Formatters.bytes(cluster.reclaimableBytesEstimate)}')),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        cluster.items.map((item) => item.fileName).join(', '),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
